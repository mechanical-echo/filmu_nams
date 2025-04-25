import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/controllers/promocode_controller.dart';
import 'package:filmu_nams/models/promocode_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditPromocodeDialog extends StatefulWidget {
  const EditPromocodeDialog({
    super.key,
    this.id,
  });

  final String? id;

  @override
  State<EditPromocodeDialog> createState() => _EditPromocodeDialogState();
}

class _EditPromocodeDialogState extends State<EditPromocodeDialog> {
  final _formKey = GlobalKey<FormState>();
  final PromocodeController _promocodeController = PromocodeController();

  Style get theme => Style.of(context);

  TextEditingController nameController = TextEditingController();
  TextEditingController valueController = TextEditingController();

  PromocodeModel? promocodeData;
  bool isLoading = true;
  bool isUpdating = false;

  // For the discount type toggle
  List<bool> isSelected = [true, false]; // [Fixed amount, Percentage]

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load promocode data if editing
      PromocodeModel? promocode;
      if (widget.id != null) {
        promocode = await _promocodeController.getPromocodeById(widget.id!);
        if (promocode != null) {
          setState(() {
            nameController.text = promocode!.name;

            // Set the correct discount type and value
            if (promocode.amount != null) {
              isSelected = [true, false]; // Fixed amount
              valueController.text = promocode.amount.toString();
            } else if (promocode.percents != null) {
              isSelected = [false, true]; // Percentage
              valueController.text = promocode.percents.toString();
            }
          });
        }
      }

      setState(() {
        promocodeData = promocode;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās ielādēt datus",
        );
      }
    }
  }

  Future<void> _savePromocode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final String name = nameController.text;
      double? amount;
      int? percents;

      // Determine discount type based on selection
      if (isSelected[0]) {
        // Fixed amount
        amount = double.tryParse(valueController.text);
      } else {
        // Percentage
        percents = int.tryParse(valueController.text);
      }

      bool success;

      if (widget.id == null) {
        // Adding a new promocode
        final String? newId = await _promocodeController.addPromocode(
          name: name,
          amount: amount,
          percents: percents,
        );

        success = newId != null;
        if (success && mounted) {
          StylizedDialog.dialog(
            Icons.check_circle_outline,
            context,
            "Veiksmīgi",
            "Promokods pievienots",
          );
        } else if (!success && mounted) {
          StylizedDialog.dialog(
            Icons.error_outline,
            context,
            "Kļūda",
            "Promokods ar šādu nosaukumu jau eksistē",
          );
        }
      } else {
        // Updating an existing promocode
        success = await _promocodeController.updatePromocode(
          id: widget.id!,
          name: name,
          amount: amount,
          percents: percents,
        );

        if (success && mounted) {
          StylizedDialog.dialog(
            Icons.check_circle_outline,
            context,
            "Veiksmīgi",
            "Promokods atjaunināts",
          );
        } else if (!success && mounted) {
          StylizedDialog.dialog(
            Icons.error_outline,
            context,
            "Kļūda",
            "Promokods ar šādu nosaukumu jau eksistē",
          );
        }
      }

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error saving promocode: $e');
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās saglabāt promokodu",
        );
      }
    }

    setState(() {
      isUpdating = false;
    });
  }

  Future<void> _deletePromocode() async {
    try {
      bool confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Dzēst promokodu?", style: theme.headlineMedium),
                content: Text(
                  "Vai tiešām vēlaties dzēst šo promokodu? Šo darbību nevar atsaukt.",
                  style: theme.bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Atcelt"),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red[700],
                    ),
                    child: const Text("Dzēst"),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (confirmDelete) {
        setState(() {
          isUpdating = true;
        });

        final bool success =
            await _promocodeController.deletePromocode(widget.id!);

        if (mounted) {
          if (success) {
            Navigator.of(context).pop();
            StylizedDialog.dialog(
              Icons.check_circle_outline,
              context,
              "Veiksmīgi",
              "Promokods dzēsts",
            );
          } else {
            setState(() {
              isUpdating = false;
            });
            StylizedDialog.dialog(
              Icons.error_outline,
              context,
              "Kļūda",
              "Nevar dzēst promokodu, kas ir piesaistīts piedāvājumam",
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error deleting promocode: $e');
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās dzēst promokodu",
        );
      }
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: isLoading || isUpdating
              ? Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: theme.contrast,
                    size: 80,
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildFormContent(),
                        const SizedBox(height: 32),
                        _buildButtonRow(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.id == null ? "Jauns promokods" : "Rediģēt promokodu",
          style: theme.displayMedium,
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, size: 24),
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Promocode name field
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Promokoda nosaukums',
            hintText: 'Ievadiet promokoda nosaukumu (piemēram, "VASARA2025")',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.confirmation_number),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lūdzu ievadiet promokoda nosaukumu';
            }
            if (value.length < 3) {
              return 'Nosaukumam jābūt vismaz 3 simboliem';
            }
            return null;
          },
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
            UpperCaseTextFormatter(),
          ],
        ),

        const SizedBox(height: 24),

        // Discount type toggle
        Text(
          'Atlaide:',
          style: theme.titleLarge,
        ),
        const SizedBox(height: 8),
        ToggleButtons(
          onPressed: (int index) {
            setState(() {
              for (int buttonIndex = 0;
                  buttonIndex < isSelected.length;
                  buttonIndex++) {
                isSelected[buttonIndex] = buttonIndex == index;
              }

              // Clear the value field when changing discount type
              valueController.clear();
            });
          },
          isSelected: isSelected,
          borderRadius: BorderRadius.circular(8),
          selectedColor: theme.onPrimary,
          fillColor: theme.primary,
          constraints: const BoxConstraints(
            minWidth: 150.0,
            minHeight: 50.0,
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Fiksēta summa (€)'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Procentuāla (%)'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Discount value field
        TextFormField(
          controller: valueController,
          decoration: InputDecoration(
            labelText: isSelected[0] ? 'Atlaide (€)' : 'Atlaide (%)',
            hintText: isSelected[0]
                ? 'Ievadiet atlaides summu'
                : 'Ievadiet atlaides procentu',
            border: OutlineInputBorder(),
            prefixIcon: Icon(isSelected[0] ? Icons.euro : Icons.percent),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: isSelected[0]),
          inputFormatters: [
            isSelected[0]
                ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                : FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lūdzu ievadiet atlaides vērtību';
            }

            if (isSelected[0]) {
              // Fixed amount validation
              double? amount = double.tryParse(value);
              if (amount == null) {
                return 'Lūdzu ievadiet derīgu summu';
              }
              if (amount <= 0) {
                return 'Summai jābūt lielākai par 0';
              }
              if (amount > 1000) {
                return 'Summa nevar pārsniegt 1000€';
              }
            } else {
              // Percentage validation
              int? percent = int.tryParse(value);
              if (percent == null) {
                return 'Lūdzu ievadiet derīgu procentu';
              }
              if (percent <= 0) {
                return 'Procentam jābūt lielākam par 0';
              }
              if (percent > 100) {
                return 'Procents nevar pārsniegt 100%';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.id != null)
          TextButton(
            onPressed: _deletePromocode,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[400],
            ),
            child: Text("Dzēst"),
          ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Atcelt"),
        ),
        const SizedBox(width: 16),
        FilledButton(
          onPressed: _savePromocode,
          child: Text(widget.id == null ? "Pievienot" : "Saglabāt"),
        ),
      ],
    );
  }
}

// Custom formatter to convert text to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
