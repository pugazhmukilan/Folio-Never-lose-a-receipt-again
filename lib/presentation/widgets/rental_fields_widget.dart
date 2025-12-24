import 'package:flutter/material.dart';
import '../../data/models/rental_data.dart';

class RentalFieldsWidget extends StatefulWidget {
  final RentalData? initialData;
  final Function(RentalData) onDataChanged;
  
  const RentalFieldsWidget({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<RentalFieldsWidget> createState() => _RentalFieldsWidgetState();
}

class _RentalFieldsWidgetState extends State<RentalFieldsWidget> {
  // Controllers
  late TextEditingController _tenantNameController;
  late TextEditingController _tenantPhoneController;
  late TextEditingController _tenantEmailController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _familyMembersController;
  late TextEditingController _propertyAddressController;
  late TextEditingController _monthlyRentController;
  late TextEditingController _securityDepositController;
  late TextEditingController _paymentDueDateController;
  late TextEditingController _agreementNumberController;
  late TextEditingController _lockInPeriodController;
  late TextEditingController _electricityMeterController;
  late TextEditingController _waterMeterController;
  late TextEditingController _gasConnectionController;
  
  // For extra charges
  final TextEditingController _chargeKeyController = TextEditingController();
  final TextEditingController _chargeValueController = TextEditingController();
  Map<String, String> _extraCharges = {};
  
  String _selectedPropertyType = 'Apartment';
  String _selectedPaymentMethod = 'Bank Transfer';
  
  // Expansion states
  bool _tenantExpanded = false;
  bool _propertyExpanded = false;
  bool _financialExpanded = false;
  bool _leaseExpanded = false;
  bool _utilitiesExpanded = false;
  
  final List<String> _propertyTypes = [
    'Apartment',
    'Villa',
    'Independent House',
    'Studio',
    'Penthouse',
    'Other'
  ];
  
  final List<String> _paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Online Payment',
    'Cheque',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    
    _tenantNameController = TextEditingController(text: data?.tenantName ?? '');
    _tenantPhoneController = TextEditingController(text: data?.tenantPhone ?? '');
    _tenantEmailController = TextEditingController(text: data?.tenantEmail ?? '');
    _emergencyContactController = TextEditingController(text: data?.emergencyContact ?? '');
    _familyMembersController = TextEditingController(text: data?.familyMembers?.toString() ?? '');
    _propertyAddressController = TextEditingController(text: data?.propertyAddress ?? '');
    _monthlyRentController = TextEditingController(text: data?.monthlyRent ?? '');
    _securityDepositController = TextEditingController(text: data?.securityDeposit ?? '');
    _paymentDueDateController = TextEditingController(text: data?.paymentDueDate ?? '');
    _agreementNumberController = TextEditingController(text: data?.agreementNumber ?? '');
    _lockInPeriodController = TextEditingController(text: data?.lockInPeriodMonths?.toString() ?? '');
    _electricityMeterController = TextEditingController(text: data?.electricityMeterReading ?? '');
    _waterMeterController = TextEditingController(text: data?.waterMeterReading ?? '');
    _gasConnectionController = TextEditingController(text: data?.gasConnectionNumber ?? '');
    
    if (data?.propertyType != null) {
      _selectedPropertyType = data!.propertyType!;
    }
    if (data?.paymentMethod != null) {
      _selectedPaymentMethod = data!.paymentMethod!;
    }
    if (data?.extraCharges != null) {
      _extraCharges = Map.from(data!.extraCharges!);
    }
    
    // Add listeners to all controllers
    _addListeners();
  }

  void _addListeners() {
    _tenantNameController.addListener(_notifyDataChanged);
    _tenantPhoneController.addListener(_notifyDataChanged);
    _tenantEmailController.addListener(_notifyDataChanged);
    _emergencyContactController.addListener(_notifyDataChanged);
    _familyMembersController.addListener(_notifyDataChanged);
    _propertyAddressController.addListener(_notifyDataChanged);
    _monthlyRentController.addListener(_notifyDataChanged);
    _securityDepositController.addListener(_notifyDataChanged);
    _paymentDueDateController.addListener(_notifyDataChanged);
    _agreementNumberController.addListener(_notifyDataChanged);
    _lockInPeriodController.addListener(_notifyDataChanged);
    _electricityMeterController.addListener(_notifyDataChanged);
    _waterMeterController.addListener(_notifyDataChanged);
    _gasConnectionController.addListener(_notifyDataChanged);
  }

  void _notifyDataChanged() {
    widget.onDataChanged(_buildRentalData());
  }

  RentalData _buildRentalData() {
    return RentalData(
      tenantName: _tenantNameController.text.isNotEmpty ? _tenantNameController.text : null,
      tenantPhone: _tenantPhoneController.text.isNotEmpty ? _tenantPhoneController.text : null,
      tenantEmail: _tenantEmailController.text.isNotEmpty ? _tenantEmailController.text : null,
      emergencyContact: _emergencyContactController.text.isNotEmpty ? _emergencyContactController.text : null,
      familyMembers: int.tryParse(_familyMembersController.text),
      propertyAddress: _propertyAddressController.text.isNotEmpty ? _propertyAddressController.text : null,
      propertyType: _selectedPropertyType,
      monthlyRent: _monthlyRentController.text.isNotEmpty ? _monthlyRentController.text : null,
      securityDeposit: _securityDepositController.text.isNotEmpty ? _securityDepositController.text : null,
      paymentDueDate: _paymentDueDateController.text.isNotEmpty ? _paymentDueDateController.text : null,
      paymentMethod: _selectedPaymentMethod,
      extraCharges: _extraCharges.isNotEmpty ? _extraCharges : null,
      agreementNumber: _agreementNumberController.text.isNotEmpty ? _agreementNumberController.text : null,
      lockInPeriodMonths: int.tryParse(_lockInPeriodController.text),
      electricityMeterReading: _electricityMeterController.text.isNotEmpty ? _electricityMeterController.text : null,
      waterMeterReading: _waterMeterController.text.isNotEmpty ? _waterMeterController.text : null,
      gasConnectionNumber: _gasConnectionController.text.isNotEmpty ? _gasConnectionController.text : null,
    );
  }

  @override
  void dispose() {
    _tenantNameController.dispose();
    _tenantPhoneController.dispose();
    _tenantEmailController.dispose();
    _emergencyContactController.dispose();
    _familyMembersController.dispose();
    _propertyAddressController.dispose();
    _monthlyRentController.dispose();
    _securityDepositController.dispose();
    _paymentDueDateController.dispose();
    _agreementNumberController.dispose();
    _lockInPeriodController.dispose();
    _electricityMeterController.dispose();
    _waterMeterController.dispose();
    _gasConnectionController.dispose();
    _chargeKeyController.dispose();
    _chargeValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Tenant Information
        _buildExpansionTile(
          title: 'Tenant Information',
          icon: Icons.person_outline,
          expanded: _tenantExpanded,
          onExpansionChanged: (value) => setState(() => _tenantExpanded = value),
          children: [
            _buildTextField(_tenantNameController, 'Tenant Name', Icons.person, optional: true),
            const SizedBox(height: 12),
            _buildTextField(_tenantPhoneController, 'Phone Number', Icons.phone, 
                keyboardType: TextInputType.phone, optional: true),
            const SizedBox(height: 12),
            _buildTextField(_tenantEmailController, 'Email', Icons.email, 
                keyboardType: TextInputType.emailAddress, optional: true),
            const SizedBox(height: 12),
            _buildTextField(_emergencyContactController, 'Emergency Contact', Icons.contact_phone,
                keyboardType: TextInputType.phone, optional: true),
            const SizedBox(height: 12),
            _buildTextField(_familyMembersController, 'Family Members', Icons.family_restroom,
                keyboardType: TextInputType.number, optional: true),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Property Details
        _buildExpansionTile(
          title: 'Property Details',
          icon: Icons.home_work_outlined,
          expanded: _propertyExpanded,
          onExpansionChanged: (value) => setState(() => _propertyExpanded = value),
          children: [
            _buildTextField(_propertyAddressController, 'Property Address/Unit', Icons.location_on, 
                maxLines: 2, optional: true),
            const SizedBox(height: 12),
            _buildDropdown('Property Type', _selectedPropertyType, _propertyTypes, (value) {
              setState(() {
                _selectedPropertyType = value!;
                _notifyDataChanged();
              });
            }),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Financial Details
        _buildExpansionTile(
          title: 'Financial Details',
          icon: Icons.attach_money,
          expanded: _financialExpanded,
          onExpansionChanged: (value) => setState(() => _financialExpanded = value),
          children: [
            _buildTextField(_monthlyRentController, 'Monthly Rent', Icons.currency_rupee,
                keyboardType: TextInputType.number, optional: true, prefix: '₹'),
            const SizedBox(height: 12),
            _buildTextField(_securityDepositController, 'Security Deposit', Icons.account_balance_wallet,
                keyboardType: TextInputType.number, optional: true, prefix: '₹'),
            const SizedBox(height: 12),
            _buildTextField(_paymentDueDateController, 'Payment Due Date', Icons.calendar_today,
                hint: 'e.g., 1st, 5th, 10th', optional: true),
            const SizedBox(height: 12),
            _buildDropdown('Payment Method', _selectedPaymentMethod, _paymentMethods, (value) {
              setState(() {
                _selectedPaymentMethod = value!;
                _notifyDataChanged();
              });
            }),
            const SizedBox(height: 16),
            _buildExtraChargesSection(),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Lease Information
        _buildExpansionTile(
          title: 'Lease Information',
          icon: Icons.description_outlined,
          expanded: _leaseExpanded,
          onExpansionChanged: (value) => setState(() => _leaseExpanded = value),
          children: [
            _buildTextField(_agreementNumberController, 'Agreement Number', Icons.numbers, optional: true),
            const SizedBox(height: 12),
            _buildTextField(_lockInPeriodController, 'Lock-in Period (months)', Icons.lock_clock,
                keyboardType: TextInputType.number, optional: true),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Utilities
        _buildExpansionTile(
          title: 'Utilities',
          icon: Icons.electrical_services,
          expanded: _utilitiesExpanded,
          onExpansionChanged: (value) => setState(() => _utilitiesExpanded = value),
          children: [
            _buildTextField(_electricityMeterController, 'Electricity Meter Reading', Icons.bolt, optional: true),
            const SizedBox(height: 12),
            _buildTextField(_waterMeterController, 'Water Meter Reading', Icons.water_drop, optional: true),
            const SizedBox(height: 12),
            _buildTextField(_gasConnectionController, 'Gas Connection Number', Icons.local_fire_department, optional: true),
          ],
        ),
      ],
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required IconData icon,
    required bool expanded,
    required Function(bool) onExpansionChanged,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: expanded ? colorScheme.primary.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          initiallyExpanded: expanded,
          onExpansionChanged: onExpansionChanged,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
    String? prefix,
    bool optional = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: '$label${optional ? ' (Optional)' : ''}',
        hintText: hint,
        prefixText: prefix,
        prefixIcon: Icon(icon, color: colorScheme.primary, size: 20),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: theme.scaffoldBackgroundColor,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildExtraChargesSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extra Charges',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        
        // Display existing charges
        if (_extraCharges.isNotEmpty) ...[
          ..._extraCharges.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                title: Text(entry.key),
                subtitle: Text('₹${entry.value}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () {
                    setState(() {
                      _extraCharges.remove(entry.key);
                      _notifyDataChanged();
                    });
                  },
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
        ],
        
        // Add new charge
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _chargeKeyController,
                decoration: InputDecoration(
                  labelText: 'Charge Name',
                  hintText: 'e.g., Water',
                  isDense: true,
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _chargeValueController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹',
                  isDense: true,
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: colorScheme.primary),
              onPressed: () {
                if (_chargeKeyController.text.isNotEmpty &&
                    _chargeValueController.text.isNotEmpty) {
                  setState(() {
                    _extraCharges[_chargeKeyController.text] = _chargeValueController.text;
                    _chargeKeyController.clear();
                    _chargeValueController.clear();
                    _notifyDataChanged();
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
