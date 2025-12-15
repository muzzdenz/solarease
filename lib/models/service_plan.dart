class ServicePlan {
  final String id;
  final String name;
  final String capacity;
  final String system;
  final String warranty;
  final String support;
  final String iconColor;
  final String price;
  final String badge;
  final String category;
  final double rating;
  final int reviews;
  final List<String> features;

  ServicePlan({
    required this.id,
    required this.name,
    required this.capacity,
    required this.system,
    required this.warranty,
    required this.support,
    required this.iconColor,
    required this.price,
    required this.badge,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.features,
  });

  static List<ServicePlan> getPlans() {
    return [
      ServicePlan(
        id: '1',
        name: 'EcoBasic',
        capacity:
            'Kapasitas 2 kWp\nDaya Ideal: Kapasitas 2 kWp (Kilowatt peak) untuk kebutuhan dasar rumah/apartemen kecil.',
        system: 'Sistem:\nInstalasi On-Grid standar dengan koneksi ke PLN.',
        warranty:
            'Garansi:\nGaransi produk 10 tahun dan garansi instalasi 1 tahun.',
        support: 'Layanan Tambahan:\nGratis survei lokasi dan konsultasi awal.',
        iconColor: '0xFF2C5F6F',
        price: 'Rp 8,5 jt',
        badge: 'Hemat',
        category: 'On-Grid',
        rating: 4.6,
        reviews: 112,
        features: const ['Survei gratis', 'Garansi 10 th', 'Instalasi cepat'],
      ),
      ServicePlan(
        id: '2',
        name: 'PowerPro',
        capacity:
            'Kapasitas 4 kWp\nDaya Ideal: Cocok untuk rumah dengan Net Metering.',
        system: 'Sistem:\nInstalasi On-Grid standar dengan koneksi ke PLN.',
        warranty:
            'Garansi:\nGaransi produk 10 tahun dan garansi instalasi 1 tahun.',
        support:
            'Layanan Tambahan:\nMonitoring sistem real-time via aplikasi IoT.',
        iconColor: '0xFF2C5F6F',
        price: 'Rp 14,9 jt',
        badge: 'Terlaris',
        category: 'On-Grid',
        rating: 4.8,
        reviews: 264,
        features: const ['Net Metering', 'Monitoring IoT', 'Upgrade baterai'],
      ),
      ServicePlan(
        id: '3',
        name: 'EnergyMax',
        capacity:
            'Kapasitas 6 kWp\nDaya Ideal: Instalasi sistem Hybrid (On-Grid + Baterai Backup).',
        system: 'Sistem:\nGaransi produk 10 tahun.',
        warranty:
            'Garansi:\nGaransi produk 10 tahun dan garansi instalasi 1 tahun.',
        support: 'Layanan Tambahan:\nGratis survei lokasi dan konsultasi awal.',
        iconColor: '0xFF2C5F6F',
        price: 'Rp 21,5 jt',
        badge: 'Hybrid Ready',
        category: 'Hybrid',
        rating: 4.7,
        reviews: 178,
        features: const ['Baterai backup', 'Monitoring IoT', 'Garansi 10 th'],
      ),
      ServicePlan(
        id: '4',
        name: 'Enterprise Custom',
        capacity:
            'Kapasitas 8 kWp+ atau lebih\nDaya Ideal: Desain sistem On-Grid/Hybrid/Off-Grid. Garansi produk dan performa premium.',
        system: 'Sistem:\nKustomisasi penuh sesuai kebutuhan.',
        warranty: 'Garansi:\nGaransi premium hingga 5 tahun.',
        support: 'Layanan Tambahan:\nPrioritas layanan dan dukungan teknis.',
        iconColor: '0xFF2C5F6F',
        price: 'Hubungi kami',
        badge: 'Kustom',
        category: 'Custom',
        rating: 4.9,
        reviews: 96,
        features: const [
          'Desain khusus',
          'SLA premium',
          'Pendampingan end-to-end'
        ],
      ),
    ];
  }
}
