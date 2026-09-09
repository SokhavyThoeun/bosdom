import 'package:flutter/material.dart';

enum FaqCategoryId {
  gettingStarted,
  ordersPayments,
  shippingDelivery,
  accountVerification,
  returnsDisputes,
}

class FaqItem {
  const FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

class FaqCategoryData {
  const FaqCategoryData({
    required this.icon,
    required this.items,
  });

  final IconData icon;
  final List<FaqItem> items;
}

const kFaqData = <FaqCategoryId, FaqCategoryData>{
  FaqCategoryId.gettingStarted: FaqCategoryData(
    icon: Icons.menu_book_rounded,
    items: [
      FaqItem(
        question: 'What is Bosdom?',
        answer:
            "Bosdom is Cambodia's premier B2B wholesale platform designed "
            'specifically to connect local retailers, supermarkets, and '
            'distributors with verified regional manufacturers and global '
            'suppliers.',
      ),
      FaqItem(
        question: 'How do I create an account?',
        answer:
            'Tap "Sign Up" on the welcome screen, choose whether you are a '
            'retailer or a supplier, then fill in your personal and business '
            'details. Suppliers also upload verification documents for review.',
      ),
      FaqItem(
        question: 'How to browse products?',
        answer:
            'Use the Home tab to explore featured categories, or the Search '
            'tab to look up a specific product, brand, or supplier by name.',
      ),
      FaqItem(
        question: 'What is MOQ?',
        answer:
            'MOQ stands for Minimum Order Quantity: the smallest amount of '
            'a product a supplier will sell in a single order. It is shown '
            'on every product page before you check out.',
      ),
      FaqItem(
        question: 'How to place my first order?',
        answer:
            'Add a product to your cart, review the quantity against the '
            "MOQ, then proceed to checkout to choose delivery, payment, and "
            'confirm your order.',
      ),
      FaqItem(
        question: 'Understanding wholesale pricing',
        answer:
            'Wholesale prices often drop as order quantity increases. Check '
            'the pricing tiers on a product page to see how much you save at '
            'higher volumes.',
      ),
    ],
  ),
  FaqCategoryId.ordersPayments: FaqCategoryData(
    icon: Icons.credit_card_rounded,
    items: [
      FaqItem(
        question: 'How to track my order?',
        answer:
            'Go to Profile > My Orders and select the order you want to '
            'follow. You will see live status updates from confirmation to '
            'delivery.',
      ),
      FaqItem(
        question: 'What payment methods are accepted?',
        answer:
            'Bosdom accepts major credit and debit cards, local bank '
            'transfers, and popular Cambodian mobile wallets. Available '
            'options are shown at checkout.',
      ),
      FaqItem(
        question: 'How does escrow payment work?',
        answer:
            "To guarantee wholesale security, your funds are safely held in "
            "Bosdom's neutral custody. Payment is only transferred to the "
            'supplier after you receive and inspect your bulk shipment, '
            'verifying it matches your requirements.',
      ),
      FaqItem(
        question: 'Can I cancel an order?',
        answer:
            'Orders can be cancelled free of charge before the supplier '
            'confirms and begins preparing them. After confirmation, contact '
            'support to request a cancellation or dispute.',
      ),
      FaqItem(
        question: 'How to request an invoice?',
        answer:
            'Open the order in My Orders and tap "Request Invoice." A PDF '
            'invoice will be generated and sent to your registered email.',
      ),
      FaqItem(
        question: 'Understanding order statuses',
        answer:
            'Orders move through Pending, Confirmed, Shipped, and Delivered. '
            'A Disputed status appears only if you raise an issue with the '
            'supplier during escrow review.',
      ),
    ],
  ),
  FaqCategoryId.shippingDelivery: FaqCategoryData(
    icon: Icons.local_shipping_rounded,
    items: [
      FaqItem(
        question: 'How long does delivery take?',
        answer:
            'Most bulk orders within Cambodia arrive within 3–7 business '
            'days, depending on the supplier location and shipment size.',
      ),
      FaqItem(
        question: 'What are the delivery fees?',
        answer:
            'Delivery fees are calculated by weight, volume, and distance, '
            'and are shown clearly before you confirm checkout.',
      ),
      FaqItem(
        question: 'Can I change my delivery address?',
        answer:
            'You can update the delivery address any time before a supplier '
            'confirms the order from your Address Book in Profile settings.',
      ),
      FaqItem(
        question: 'Do you deliver outside Phnom Penh?',
        answer:
            'Yes, Bosdom partners with logistics providers that cover all '
            'provinces across Cambodia.',
      ),
      FaqItem(
        question: 'What if my shipment arrives damaged?',
        answer:
            'Report the issue with photos through Delivery Tracking within '
            '48 hours of receipt. Escrow funds stay protected until the '
            'issue is resolved.',
      ),
    ],
  ),
  FaqCategoryId.accountVerification: FaqCategoryData(
    icon: Icons.verified_user_rounded,
    items: [
      FaqItem(
        question: 'Why do I need to verify my business?',
        answer:
            'Verification confirms you are a genuine retailer or supplier, '
            'which builds trust across the marketplace and unlocks wholesale '
            'pricing and escrow protection.',
      ),
      FaqItem(
        question: 'What documents are required?',
        answer:
            'Suppliers typically submit a business registration certificate '
            'and a valid ID. Retailers may verify with a business license or '
            'storefront proof.',
      ),
      FaqItem(
        question: 'How long does verification take?',
        answer:
            'Most accounts are reviewed within 1–2 business days. You will '
            'get a notification as soon as a decision is made.',
      ),
      FaqItem(
        question: 'How do I update my business information?',
        answer:
            'Go to Profile > Edit Profile to update your business details. '
            'Changes to verification documents may require re-review.',
      ),
      FaqItem(
        question: 'I forgot my password, what do I do?',
        answer:
            'Tap "Forgot Password" on the login screen and follow the steps '
            'to reset it using your registered phone number or email.',
      ),
    ],
  ),
  FaqCategoryId.returnsDisputes: FaqCategoryData(
    icon: Icons.replay_rounded,
    items: [
      FaqItem(
        question: 'What is the return policy?',
        answer:
            'Bulk orders can be returned if the goods do not match the '
            'listing description, are damaged, or fail quality inspection, '
            'as long as it is reported before escrow funds are released.',
      ),
      FaqItem(
        question: 'How do I open a dispute?',
        answer:
            'Go to the order in My Orders and tap "Report an Issue." Add '
            'photos and a description, and our support team will step in to '
            'mediate with the supplier.',
      ),
      FaqItem(
        question: 'How long does a dispute resolution take?',
        answer:
            'Most disputes are resolved within 3–5 business days once both '
            'parties have submitted their evidence.',
      ),
      FaqItem(
        question: 'Will I get a refund?',
        answer:
            'If a dispute is resolved in your favor, escrowed funds are '
            'refunded to your original payment method within 5–7 business '
            'days.',
      ),
      FaqItem(
        question: 'Can suppliers dispute a return?',
        answer:
            'Yes, suppliers can respond with their own evidence. Bosdom '
            'support reviews both sides before making a final decision.',
      ),
    ],
  ),
};
