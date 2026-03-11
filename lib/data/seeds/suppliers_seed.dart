import '../../services/suppliers_service.dart';

class SuppliersSeed {
  static final List<Map<String, String>> data = [
    {
      'name': 'A-1 Industries',
      'contact': 'Nawab',
      'phone': '8087610621',
      'status': 'active',
    },
    {
      'name': 'Anil Coconut oil',
      'contact': 'Anil Pardeshi',
      'phone': '9960710039',
      'status': 'active',
    },
    {
      'name': 'Arujit Petrolium',
      'contact': 'Arujit',
      'phone': '45645645678',
      'status': 'active',
    },
    {
      'name': 'Ashok Jain',
      'contact': 'Prashant Parakh',
      'phone': '9377909618',
      'status': 'active',
    },
    {
      'name': 'Deccan Soap Factory',
      'contact': 'Radhakishan Jadhav',
      'phone': '9850436082',
      'status': 'active',
    },
    {
      'name': 'Gopal Company',
      'contact': 'Ganesh',
      'phone': '9422110860',
      'status': 'active',
    },
    {
      'name': 'Jain Acid',
      'contact': 'Sumit Jain',
      'phone': '7350008011',
      'status': 'active',
    },
    {
      'name': 'Manish Bhaya',
      'contact': 'Manish',
      'phone': '9425053243',
      'status': 'active',
    },
    {
      'name': 'Mujju Traders',
      'contact': 'Mujju',
      'phone': '1554154554',
      'status': 'inactive',
    },
    {
      'name': 'Poddar Chemical',
      'contact': 'Anant Kishor',
      'phone': '9225826200',
      'status': 'active',
    },
    {
      'name': 'R K Microns',
      'contact': 'Ravi Teja',
      'phone': '9440291128',
      'status': 'active',
    },
    {
      'name': 'Rama Krishana',
      'contact': 'Rama Krishana',
      'phone': '8636640236',
      'status': 'active',
    },
    {
      'name': 'S K Broker',
      'contact': 'Sunil Jadwani',
      'phone': '9425058538',
      'status': 'active',
    },
    {
      'name': 'Samarth Chemicals',
      'contact': 'Tiwari',
      'phone': '7499648101',
      'status': 'active',
    },
    {
      'name': 'Select Magname Chem',
      'contact': 'Shirish Kond',
      'phone': '9326206004',
      'status': 'active',
    },
    {
      'name': 'Srinivas Babu',
      'contact': 'Srinvas',
      'phone': '9490187444',
      'status': 'active',
    },
    {
      'name': 'SRV',
      'contact': 'Kuldeep Jadhav',
      'phone': '8124817834',
      'status': 'active',
    },
    {
      'name': 'Suhail Trading co.',
      'contact': 'Suhail',
      'phone': '9573378614',
      'status': 'active',
    },
    {
      'name': 'Taher Bhai',
      'contact': 'Taher Bhai',
      'phone': '9325232656',
      'status': 'active',
    },
    {
      'name': 'Union Agro',
      'contact': 'Vinod Kumar',
      'phone': '9893176644',
      'status': 'active',
    },
    {
      'name': 'Venkatesh Trading',
      'contact': 'Mr. Kulkarni',
      'phone': '8657777061',
      'status': 'active',
    },
    {
      'name': 'Veriq Minerals',
      'contact': 'Anil Motwani',
      'phone': '9414162151',
      'status': 'active',
    },
    {
      'name': 'Vijay Agarawal',
      'contact': 'Vijay',
      'phone': '8839990892',
      'status': 'active',
    },
    {
      'name': 'void Inpex',
      'contact': 'Ashish Joshi',
      'phone': '7874004242',
      'status': 'active',
    },
  ];

  static Future<void> import(SuppliersService service) async {
    for (final item in data) {
      await service.addSupplier(
        name: item['name']!,
        contactPerson: item['contact']!,
        mobile: item['phone']!,
        address: 'N/A',
        status: item['status']!,
      );
    }
  }
}
