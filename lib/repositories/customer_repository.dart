import '../models/customer.dart';
import '../services/api_service.dart';

class CustomerRepository {
  Future<List<Customer>> fetchCustomers() async {
    final customersJson = await ApiService.fetch('customers');
    return customersJson.map<Customer>((e) => Customer.fromJson(e)).toList();
  }
}
