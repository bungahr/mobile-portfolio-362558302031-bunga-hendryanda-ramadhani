import 'package:flutter/material.dart';

class FieldKataSandi extends StatefulWidget {
  const FieldKataSandi({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  State<FieldKataSandi> createState() => _FieldKataSandiState();
}

class _FieldKataSandiState extends State<FieldKataSandi> {
  bool _terlihat = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      enabled: widget.enabled,
      obscureText: !_terlihat,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: const [AutofillHints.password],
      textInputAction: widget.textInputAction,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        labelText: 'Kata sandi',
        hintText: 'Masukkan kata sandi',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _terlihat ? 'Sembunyikan kata sandi' : 'Lihat kata sandi',
          onPressed: widget.enabled
              ? () {
                  setState(() {
                    _terlihat = !_terlihat;
                  });
                }
              : null,
          icon: Icon(_terlihat ? Icons.visibility_off : Icons.visibility),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
