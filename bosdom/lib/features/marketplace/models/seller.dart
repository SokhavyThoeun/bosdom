import 'package:flutter/material.dart';

class SellerCertification {
  const SellerCertification({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class SellerHighlight {
  const SellerHighlight({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class SellerReview {
  const SellerReview({
    required this.reviewerName,
    required this.date,
    required this.rating,
    required this.comment,
  });

  final String reviewerName;
  final String date;
  final int rating;
  final String comment;
}

class Seller {
  const Seller({
    required this.name,
    required this.icon,
    required this.rating,
    required this.location,
    required this.verified,
    required this.productsCount,
    required this.ordersCount,
    required this.about,
    required this.businessType,
    required this.yearEstablished,
    required this.minimumOrder,
    required this.responseTime,
    required this.shipping,
    required this.certifications,
    required this.highlights,
    this.reviewsCount = '0',
    this.recommendPercent = 0,
    this.ratingBreakdown = const {},
    this.reviews = const [],
  });

  final String name;
  final IconData icon;
  final double rating;
  final String location;
  final bool verified;
  final int productsCount;
  final String ordersCount;
  final String about;
  final String businessType;
  final String yearEstablished;
  final String minimumOrder;
  final String responseTime;
  final String shipping;
  final List<SellerCertification> certifications;
  final List<SellerHighlight> highlights;
  final String reviewsCount;
  final int recommendPercent;
  final Map<int, int> ratingBreakdown;
  final List<SellerReview> reviews;
}

const kMockSellers = <String, Seller>{
  'Mekong Agri-Food Co.': Seller(
    name: 'Mekong Agri-Food Co.',
    icon: Icons.rice_bowl_outlined,
    rating: 4.5,
    location: 'Phnom Penh, Cambodia',
    verified: true,
    productsCount: 48,
    ordersCount: '1.2K',
    about:
        'Mekong Agri-Food Co. is a trusted wholesale supplier of premium '
        'Cambodian agricultural products, proudly serving retailers and '
        'restaurants across the region since 2018. We specialize in '
        'sustainably sourced rice, traditional fish sauce, organic coconut '
        "oils, and artisan palm sugar - connecting Cambodia's finest "
        'producers directly to your shelves.',
    businessType: 'Walk-in Store & Distributor',
    yearEstablished: '2018',
    minimumOrder: '\$50 USD',
    responseTime: 'Within 24 hours',
    shipping: 'Nationwide',
    certifications: [
      SellerCertification(label: 'HACCP', icon: Icons.shield_outlined),
      SellerCertification(label: 'ISO 9001', icon: Icons.verified_outlined),
      SellerCertification(label: 'Organic Certified', icon: Icons.eco_outlined),
      SellerCertification(label: 'Fair Trade', icon: Icons.workspace_premium_outlined),
    ],
    highlights: [
      SellerHighlight(
        title: 'Direct from Source',
        description: 'We work directly with Cambodian farmers.',
        icon: Icons.link,
      ),
      SellerHighlight(
        title: 'Quality Guaranteed',
        description: 'All products pass strict quality checks.',
        icon: Icons.check_circle_outline,
      ),
      SellerHighlight(
        title: 'Fast Delivery',
        description: 'Orders processed within 24 hours.',
        icon: Icons.bolt_outlined,
      ),
    ],
    reviewsCount: '1.2K',
    recommendPercent: 90,
    ratingBreakdown: {5: 72, 4: 18, 3: 6, 2: 3, 1: 1},
    reviews: [
      SellerReview(
        reviewerName: 'Sokhavy Thoeun',
        date: 'Jan 12, 2025',
        rating: 5,
        comment:
            'Fast response and consistent quality. The jasmine rice bulk '
            'bags are always well packaged and delivered on time.',
      ),
      SellerReview(
        reviewerName: 'Dara Meas',
        date: 'Jan 05, 2025',
        rating: 4,
        comment:
            'Good product range. Minimum order quantity is fair for small '
            'retailers like us.',
      ),
      SellerReview(
        reviewerName: 'Channary Sok',
        date: 'Dec 20, 2024',
        rating: 3,
        comment:
            'Best wholesale supplier in Phnom Penh. Great prices on '
            'organic products.',
      ),
    ],
  ),
};

Seller sellerFor(String name, {required IconData icon, required double rating, required String location, required bool verified}) {
  return kMockSellers[name] ??
      Seller(
        name: name,
        icon: icon,
        rating: rating,
        location: location,
        verified: verified,
        productsCount: 12,
        ordersCount: '340',
        about:
            '$name is a wholesale supplier on BosDom, connecting quality '
            'products with retailers and restaurants across Cambodia.',
        businessType: 'Distributor',
        yearEstablished: '2020',
        minimumOrder: '\$30 USD',
        responseTime: 'Within 48 hours',
        shipping: 'Phnom Penh & nearby provinces',
        certifications: const [
          SellerCertification(label: 'Verified Seller', icon: Icons.verified_outlined),
        ],
        highlights: const [
          SellerHighlight(
            title: 'Trusted Seller',
            description: 'Active member of the BosDom marketplace.',
            icon: Icons.storefront_outlined,
          ),
        ],
      );
}
