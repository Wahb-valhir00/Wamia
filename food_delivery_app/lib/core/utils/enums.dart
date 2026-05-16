enum UserRole { customer, restaurant, driver }

enum OrderStatus {
  created,
  accepted,
  preparing,
  ready,
  assigned,
  pickedUp,
  delivered,
}

enum DriverAvailability { online, offline, busy }

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.customer:
        return 'ROLE_CUSTOMER';
      case UserRole.restaurant:
        return 'ROLE_RESTAURANT';
      case UserRole.driver:
        return 'ROLE_DRIVER';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'ROLE_CUSTOMER':
        return UserRole.customer;
      case 'ROLE_RESTAURANT':
        return UserRole.restaurant;
      case 'ROLE_DRIVER':
        return UserRole.driver;
      default:
        throw ArgumentError('Unknown role: $role');
    }
  }
}

extension OrderStatusX on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.created:
        return 'CREATED';
      case OrderStatus.accepted:
        return 'ACCEPTED';
      case OrderStatus.preparing:
        return 'PREPARING';
      case OrderStatus.ready:
        return 'READY';
      case OrderStatus.assigned:
        return 'ASSIGNED';
      case OrderStatus.pickedUp:
        return 'PICKED_UP';
      case OrderStatus.delivered:
        return 'DELIVERED';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return OrderStatus.created;
      case 'ACCEPTED':
        return OrderStatus.accepted;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'READY':
        return OrderStatus.ready;
      case 'ASSIGNED':
        return OrderStatus.assigned;
      case 'PICKED_UP':
        return OrderStatus.pickedUp;
      case 'DELIVERED':
        return OrderStatus.delivered;
      default:
        return OrderStatus.created;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.created:
        return 'Order Placed';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.assigned:
        return 'Driver Assigned';
      case OrderStatus.pickedUp:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }
}

extension DriverAvailabilityX on DriverAvailability {
  String get value {
    switch (this) {
      case DriverAvailability.online:
        return 'ONLINE';
      case DriverAvailability.offline:
        return 'OFFLINE';
      case DriverAvailability.busy:
        return 'BUSY';
    }
  }

  static DriverAvailability fromString(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return DriverAvailability.online;
      case 'OFFLINE':
        return DriverAvailability.offline;
      case 'BUSY':
        return DriverAvailability.busy;
      default:
        return DriverAvailability.offline;
    }
  }
}
