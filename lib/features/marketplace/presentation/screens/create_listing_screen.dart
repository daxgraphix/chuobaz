import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/listing_model.dart';
import '../providers/marketplace_provider.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});
  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _location = TextEditingController();
  ListingCategory _category = ListingCategory.books;
  bool _saving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _saving = true);
    final listing = ListingModel(
      id: '',
      sellerId: user.id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      price: double.tryParse(_price.text.trim()) ?? 0,
      category: _category,
      location: _location.text.trim().isEmpty ? null : _location.text.trim(),
      createdAt: DateTime.now(),
    );
    final result = await ref.read(marketplaceRepositoryProvider).createListing(listing);
    setState(() => _saving = false);
    if (!mounted) return;
    result.fold(
      (failure) => context.showSnack(failure.message, isError: true),
      (created) {
        context.showSnack('Listing published');
        Navigator.pop(context, created);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Listing')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<ListingCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ListingCategory.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 16),
              AppTextField(controller: _title, label: 'Title', validator: (v) => Validators.required(v, field: 'Title')),
              const SizedBox(height: 16),
              AppTextField(controller: _description, label: 'Description', maxLines: 5, validator: (v) => Validators.required(v, field: 'Description')),
              const SizedBox(height: 16),
              AppTextField(controller: _price, label: 'Price (TZS)', keyboardType: TextInputType.number, validator: Validators.price),
              const SizedBox(height: 16),
              AppTextField(controller: _location, label: 'Location (optional)'),
              const SizedBox(height: 28),
              AppButton(label: 'Publish Listing', isLoading: _saving, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
