class ServicePlan {
  final String id;
  final String name;
  final String capacity;
  final String system;
  final String warranty;
  final String support;
  final String iconColor;

  ServicePlan({
    required this.id,
    required this.name,
    required this.capacity,
    required this.system,
    required this.warranty,
    required this.support,
    required this.iconColor,
  });

  static List<ServicePlan> getPlans() {
    return [
      ServicePlan(
        id: '1',
        name: 'EcoBasic',
        capacity: 'Kapasitas 2 kWp\nDaya Ideal: Kapasitas 2 kWp (Kilowatt peak) untuk kebutuhan dasar rumah/apartemen kecil.',
        system: 'Sistem:\nInstalasi On-Grid standar dengan koneksi ke PLN.',
        warranty: 'Garansi:\nGaransi produk 10 tahun dan garansi instalasi 1 tahun.',
        support: 'Layanan Tambahan:\nGratis survei lokasi dan konsultasi awal.',
        iconColor: '0xFF2C5F6F',
      ),
      ServicePlan(
        id: '2',
        name: 'PowerPro',
        capacity: 'Kapasitas 4 kWp\nDaya Ideal: Cocok untuk rumah dengan Net Metering.',
        system: 'Sistem:\nInstalasi On-Grid standar dengan koneksi ke PLN.',
        warranty: 'Garansi:\nGaransi produk 10 tahun dan garansi instalasi 1 tahun.',
        support: 'Layanan Tambahan:\nMonitoring sistem real-time via aplikasi IoT.',
        iconColor: '0xFF2C5F6F',
      ),
      ServicePlan(
        id: '3',
        name: 'EnergyMax',
        capacity: 'Kapasitas 6 kWp\nDaya Ideal: Instalasi sistem Hybrid (On-Grid + Baterai Backup).',
        system: 'Sistem:\nGaransi produk 10 tahun.',
        warranty: 'Garansi:\nGaransi produk 10 tahun dan garansi instalasi 1 tahun.',
        support: 'Layanan Tambahan:\nGratis survei lokasi dan konsultasi awal.',
        iconColor: '0xFF2C5F6F',
      ),
      ServicePlan(
        id: '4',
        name: 'Enterprise Custom',
        capacity: 'Kapasitas 8 kWp+ atau lebih\nDaya Ideal: Desain sistem On-Grid/Hybrid/Off-Grid. Garansi produk dan performa premium.',
        system: 'Sistem:\nKustomisasi penuh sesuai kebutuhan.',
        warranty: 'Garansi:\nGaransi premium hingga 5 tahun.',
        support: 'Layanan Tambahan:\nPrioritas layanan dan dukungan teknis.',
        iconColor: '0xFF2C5F6F',
      ),
    ];
  }
}