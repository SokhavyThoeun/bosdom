/// Curated, verified real photos (hosted on Wikimedia Commons) keyed by the
/// same topic tag used across the app's mock data (e.g. 'rice,sack').
///
/// Previously this pulled from loremflickr.com's keyword search, which now
/// fails (HTTP 500) for most tags — hence a hand-picked, stable set here
/// instead of a live query API.
const Map<String, String> _curatedPhotoUrls = {
  'rice,sack':
      'https://commons.wikimedia.org/wiki/Special:FilePath/US_Navy_080630-N-5961C-009_Lt._Brandon_Sheets%2C_right%2C_carries_a_100-pound_sack_of_rice_while_a_soldier_from_the_Armed_Forces_of_the_Philippines_lends_a_hand_trying_to_keep_the_bag_closed.jpg?width=600',
  'paper,cup':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Focovir_paper_cups_and_bowls.jpg?width=600',
  'usb,charger':
      'https://commons.wikimedia.org/wiki/Special:FilePath/USB_Type-C_Cable_-_iPad_USB-C_Charger_%2845640822114%29.jpg?width=600',
  'coconut,oil':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Coconut_oil_bottle_in_the_background_of_coconuts_from_Kaleeswari_Farm.jpg?width=600',
  'tote,bag':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Canvas_tote_bag_from_Books_%26_Books%2C_Miami%2C_Florida%2C_USA_-_20130912.jpg?width=600',
  'cleaning,cloth':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Microfiber_cloth.jpg?width=600',
  'snack,mix':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Trail_Mix.JPG?width=600',
  'face,mask':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Disposable_Blue_Face_Masks_%2850642389342%29.jpg?width=600',
  'water,bottle':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Stainless_steel_water_bottle.jpg?width=600',
  'wireless,earbuds':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Yamaha_TW-E3A_Earbuds_Customize%2C_Japan%3B_April_2021_%2801%29.jpg?width=600',
  'tshirt,stack':
      'https://commons.wikimedia.org/wiki/Special:FilePath/T-Shirt_folding_skills_%284111373509%29.jpg?width=600',
  'paper,towel':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Roll_of_Paper_Towels.jpg?width=600',
  'brown,sugar':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Brown_sugar_and_muscovado.jpg?width=600',
  'fish,sauce':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Thaifishsauce0609.jpg?width=600',
  'green,tea':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Green_tea_leaves_and_a_cloudy_sky_01.jpg?width=600',
  'dried,mango':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Dried_Mango_Slices.JPG?width=600',
  'coconut,milk':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Coconut_milk_from_can01.JPG?width=600',
  'palm,sugar':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Palm_Sugar_at_Bakin_Dogo_Market%2C_Kaduna_North_01.jpg?width=600',
  'jasmine,rice,bag':
      'https://commons.wikimedia.org/wiki/Special:FilePath/HK_TKO_Spot_mall_%E5%B0%87%E8%BB%8D%E6%BE%B3_Tseung_Kwan_O_MTR_train_%E8%8C%89%E8%8E%89%E9%A6%99%E7%B1%B3_Jasmine_white_rice_bag_%E4%BA%94%E8%B1%90%E7%89%8C_Ng_Fung_brand_January_2023_Px3_01.jpg?width=600',
  'roasted,cashew,nuts':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Roasted_Cashew_Nuts_%2852746470588%29.jpg?width=600',
  'wholesale,shipping,box':
      'https://commons.wikimedia.org/wiki/Special:FilePath/Cardboard_boxes_in_different_sizes_for_sale_-_Thailand_Post.JPG?width=600',
};

const _fallbackPhotoUrl =
    'https://commons.wikimedia.org/wiki/Special:FilePath/Cardboard_boxes_in_different_sizes_for_sale_-_Thailand_Post.JPG?width=600';

/// Real, topic-matched mock photo for [query] (e.g. 'rice,sack'). Falls back
/// to a generic wholesale-box photo for any tag not in the curated set (e.g.
/// a free-text cart item name), so a photo always renders.
String mockPhotoUrl(String query, String seed, {int size = 400}) {
  return _curatedPhotoUrls[query] ?? _fallbackPhotoUrl;
}

/// Polished abstract mock logo (no letters, no faces) standing in for a
/// store/seller's brand mark — a glossy circular badge, closer to a real
/// app/store icon than a generic placeholder.
String mockStoreLogoUrl(String storeName, {int size = 128}) {
  return 'https://api.dicebear.com/9.x/glass/png'
      '?seed=${Uri.encodeComponent(storeName)}'
      '&size=$size';
}
