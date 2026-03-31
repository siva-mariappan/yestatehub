import '../models/property.dart';

/// Mock data for YEstateHub development
class MockData {
  MockData._();

  static const List<String> cities = [
    'Hyderabad',
    'Bangalore',
    'Mumbai',
    'Delhi NCR',
    'Chennai',
    'Pune',
    'Kolkata',
    'Ahmedabad',
  ];

  static const List<String> popularLocalities = [
    'Gachibowli',
    'Hitech City',
    'Kondapur',
    'Madhapur',
    'Miyapur',
    'Kukatpally',
    'Banjara Hills',
    'Jubilee Hills',
    'Manikonda',
    'Nallagandla',
    'Tellapur',
    'Kokapet',
  ];

  static final List<Property> featuredProperties = [];

  // ─── Featured Services (large cards with bg images & offer badges) ────
  static final List<ServiceCategory> featuredServices = [
    const ServiceCategory(
      id: 's2',
      name: 'Rental\nAgreement',
      icon: 'description',
      description: 'Get rental agreement delivered at your doorstep',
      imageUrl: 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=400',
      offerText: 'UPTO 30% OFF',
      isFeatured: true,
    ),
    const ServiceCategory(
      id: 's4',
      name: 'Cleaning',
      icon: 'cleaning_services',
      description: 'Professional deep cleaning for your home',
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
      offerText: 'UPTO 20% OFF',
      isFeatured: true,
    ),
  ];

  // ─── Regular Services (small image cards) ───────────────────────────
  static final List<ServiceCategory> services = [
    const ServiceCategory(
      id: 's3',
      name: 'Packers &\nMovers',
      icon: 'local_shipping',
      description: 'Trusted movers at best prices',
      imageUrl: 'https://images.unsplash.com/photo-1600518464441-9154a4dea21b?w=300',
    ),
    const ServiceCategory(
      id: 's7',
      name: 'Painting',
      icon: 'format_paint',
      description: 'Transform your walls professionally',
      imageUrl: 'https://images.unsplash.com/photo-1562259929-b4e1fd3aef09?w=300',
    ),
    const ServiceCategory(
      id: 's9',
      name: 'Repair',
      icon: 'plumbing',
      description: 'Plumbing, electrical & more',
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=300',
    ),
    const ServiceCategory(
      id: 's1',
      name: 'Rent\nPayment',
      icon: 'payment',
      description: 'Pay rent via UPI, cards & earn rewards',
      imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=300',
    ),
    const ServiceCategory(
      id: 's5',
      name: 'Interior\nDesign',
      icon: 'chair',
      description: 'Design & furnish your dream home',
      imageUrl: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=300',
    ),
    const ServiceCategory(
      id: 's6',
      name: 'Legal\nHelp',
      icon: 'gavel',
      description: 'Property legal verification & docs',
      imageUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=300',
    ),
    const ServiceCategory(
      id: 's8',
      name: 'AC\nService',
      icon: 'ac_unit',
      description: 'AC repair, installation & servicing',
      imageUrl: 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=300',
    ),
    const ServiceCategory(
      id: 's10',
      name: 'Electrician',
      icon: 'electrical_services',
      description: 'Wiring, repairs & installations',
      imageUrl: 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=300',
    ),
    const ServiceCategory(
      id: 's11',
      name: 'Home\nLoan',
      icon: 'account_balance',
      description: 'Compare & get best home loan rates',
      imageUrl: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=300',
    ),
    const ServiceCategory(
      id: 's12',
      name: 'Vastu\nConsulting',
      icon: 'explore',
      description: 'Vastu consultation for your property',
      imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=300',
    ),
    const ServiceCategory(
      id: 's13',
      name: 'Keeper',
      icon: 'vpn_key',
      description: 'Trusted property keepers & caretakers',
      imageUrl: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=300',
    ),
    const ServiceCategory(
      id: 's14',
      name: 'Caregiver',
      icon: 'favorite',
      description: 'Elderly care & home nursing services',
      imageUrl: 'https://images.unsplash.com/photo-1576765608535-5f04d1e3f289?w=300',
    ),
  ];

  static const List<String> quickFilters = [
    '2 BHK',
    'Under 20K',
    'Ready to Move',
    'Verified Owner',
    'Zero Brokerage',
    'With Photos',
    'Near Metro',
  ];

  static final List<PriceTrend> priceTrends = [
    const PriceTrend(quarter: 'Q1 24', pricePerSqft: 5800),
    const PriceTrend(quarter: 'Q2 24', pricePerSqft: 5950),
    const PriceTrend(quarter: 'Q3 24', pricePerSqft: 6100),
    const PriceTrend(quarter: 'Q4 24', pricePerSqft: 6300),
    const PriceTrend(quarter: 'Q1 25', pricePerSqft: 6450),
    const PriceTrend(quarter: 'Q2 25', pricePerSqft: 6700),
    const PriceTrend(quarter: 'Q3 25', pricePerSqft: 6850),
    const PriceTrend(quarter: 'Q4 25', pricePerSqft: 7100),
  ];

  static const LocalityScore gachibowliScore = LocalityScore(
    name: 'Gachibowli',
    connectivity: 4.2,
    safety: 4.0,
    lifestyle: 4.5,
    environment: 3.8,
    valueForMoney: 3.5,
  );
}
