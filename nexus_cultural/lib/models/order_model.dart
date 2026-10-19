import 'artisan_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;

  const CartItemModel({
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;

  CartItemModel copyWith({ProductModel? product, int? quantity}) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class ShippingAddressModel {
  final String fullName;
  final String phone;
  final String department;
  final String city;
  final String address;
  final String deliveryNotes;

  const ShippingAddressModel({
    required this.fullName,
    required this.phone,
    required this.department,
    required this.city,
    required this.address,
    required this.deliveryNotes,
  });
}

enum PaymentMethodType { card, pse, wallet }

class OrderModel {
  final String id;
  final String orderNumber;
  final String orderDate;
  final List<CartItemModel> items;
  final double totalAmount;
  final double artisanDirectPayout; // 90% ethical payout
  final ShippingAddressModel shippingAddress;
  final PaymentMethodType paymentMethod;
  final String carrierName;
  final String trackingGuide;
  final int currentStage; // 1 to 5
  final String estimatedDelivery;
  final String? dedicationNote;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.items,
    required this.totalAmount,
    required this.artisanDirectPayout,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.carrierName,
    required this.trackingGuide,
    required this.currentStage,
    required this.estimatedDelivery,
    this.dedicationNote,
  });
}
