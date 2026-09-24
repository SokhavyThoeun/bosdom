# ABA PayWay card payments (`payment_option=cards`): what actually works

Everything below was tested against the PayWay sandbox while building Niyey's checkout.

## 0. Setup facts (confirmed by testing and by ABA)

- **Sandbox base URL:** `https://checkout-sandbox.payway.com.kh`
- **No whitelisting or activation is needed for the sandbox.** ABA confirmed this, and card checkout, the QR API and Check Transaction all work straight away.
- **Credentials:** the **merchant ID**, plus the key ABA's email calls the **"public key"**, which is the **HMAC signing key** (the docs call it `api_key`). The two **RSA keys are not needed** for card payments; only the Payment Link API uses them.
- **Never put the key in the iOS app.** Build and sign requests on a backend; the app only gets the signed fields or a URL.

## 1. Signing (the #1 cause of "not working")

`hash = base64( HMAC-SHA512(key = API key, message = values concatenated in the EXACT documented order) )`

For the Purchase API, the order is:

```
req_time + merchant_id + tran_id + amount + items + shipping + firstname + lastname +
email + phone + type + payment_option + return_url + cancel_url + continue_success_url +
return_deeplink + currency + custom_fields + return_params + payout + lifetime +
additional_params + google_pay_token + skip_success_page
```

- **Every field you don't send counts as an empty string** in that order. Don't skip positions.
- The hashed value must be **byte-identical** to the value sent. For example, send amount `"9.99"` and hash `"9.99"`, not `9.990`.
- `req_time` is **UTC**, formatted `YYYYMMDDHHmmss`.
- `tran_id` must be unique and **at most 20 characters**.
- `items` is **base64 of a JSON array**. `return_url` is **base64** too.
- `payment_gate` and `view_type` are **not** part of the hash.
- A wrong hash returns **HTTP 403** with `{"code":1 or 5,"message":"wrong hash"}`. An empty or missing key on the server gives exactly this, so check the server's environment variables first.

```python
import base64, hashlib, hmac

def sign(api_key: str, *values: str) -> str:
    return base64.b64encode(
        hmac.new(api_key.encode(), "".join(values).encode(), hashlib.sha512).digest()
    ).decode()
```

## 2. The card request

`POST {base}/api/payment-gateway/v1/payments/purchase` as **`multipart/form-data`**:

| field | value |
|---|---|
| `req_time`, `merchant_id`, `tran_id`, `amount`, `currency` | e.g. `USD` |
| `payment_option` | `cards` |
| **`payment_gate`** | **`0`**, see below |
| `items`, `email` | optional, but include them in the hash if sent |
| `continue_success_url` | where to send the payer after paying (see §3) |
| `skip_success_page` | `1` to skip PayWay's own success screen |
| `hash` | as in §1 |

> ⚠️ **The biggest trap:** the sandbox profile has the QR API enabled by default. Without `payment_gate=0`, the Purchase API **ignores `payment_option=cards` and returns KHQR JSON (`qrString`…) instead of the card form.** Every card request needs `payment_gate=0`.

A correct request returns a **302 redirect** to `…/checkout/<long base64>`, which is PayWay's hosted card page (HTML). That page has to be shown in a web view; there's no JSON card API.

## 3. How to do it on iOS

Don't use `checkout2-0.js`: that's PayWay's popup script for websites.

The simplest reliable pattern:

1. The app calls **your backend**, which creates `tran_id`, records the payment as pending, and builds and signs the fields.
2. The backend serves a tiny **auto-submitting HTML page**, e.g. `GET /pay/card/{tran_id}`:

   ```html
   <form id="f" method="POST" action="https://checkout-sandbox.payway.com.kh/api/payment-gateway/v1/payments/purchase">
     <input type="hidden" name="req_time" value="…">
     <!-- …every other signed field… -->
     <input type="hidden" name="hash" value="…">
   </form>
   <script>document.getElementById('f').submit()</script>
   ```

3. The app opens that URL in a **`WKWebView`**. This is easier than building the POST in Swift, because `WKWebView` is unreliable with POST bodies.
4. Set `continue_success_url` to a URL you own, e.g. `https://yourbackend/payway/done?tran=…`. In `webView(_:decidePolicyFor:)`, when that URL shows up: **cancel the navigation, close the web view, and ask your backend for the result.**
5. **Never trust the redirect alone.** The backend confirms with **Check Transaction** (§4) before granting anything. Also poll that endpoint from the app while the web view is open, in case the redirect never fires.

## 4. Confirming the payment (server-side)

`POST {base}/api/payment-gateway/v1/payments/check-transaction-2`, sent as **JSON**:

```json
{
  "req_time": "...",
  "merchant_id": "...",
  "tran_id": "...",
  "hash": "<sign(req_time + merchant_id + tran_id)>"
}
```

- **Paid:** `status.code == "00"` and `data.payment_status == "APPROVED"`. Also check that `data.total_amount` matches what you charged.
- **Not paid yet:** `PENDING`.
- **Failed:** `DECLINED`, `CANCELLED` or `REFUNDED`.
- **`code 6` "tran_id not found"** means the purchase request was never accepted, which usually points back to a wrong hash in §2.

## 5. Sandbox test cards

| Card | Number | Exp | CVV | 3-D Secure |
|---|---|---|---|---|
| Mastercard | `5156 8399 3770 6777` | 01/30 | 993 | **No**: straight to success |
| Visa | `4286 0900 0000 0206` | 04/30 | 777 | Yes: shows a sandbox "Approve / Decline" page |

## 6. Error codes we hit

| Response | Meaning |
|---|---|
| 403, code 1 or 5 "wrong hash" | wrong key, wrong field order, or a hashed value differs from the sent value |
| KHQR JSON instead of the card page | `payment_gate=0` is missing |
| `104` "Merchant not enabled token flag" | saved cards / subscriptions (`token_flag`, `ctid`) aren't enabled on the profile; one-off card payments still work |
| `6` "tran_id not found" (Check Transaction) | the purchase was never accepted |
| Blank web view showing raw JSON | PayWay rejected the form; read the JSON, it's usually a wrong hash |

**Also:** sandbox KHQR codes point at a placeholder account (`abaakhppxxx@abaa` / `111111111111111`), so real banking apps can't pay them. Testing KHQR needs ABA's simulator app. Cards can be fully tested with the test cards above.
