import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/controllers/offer_controller.dart';
import 'package:filmu_nams/models/offer_model.dart';
import 'package:filmu_nams/models/promocode_model.dart';
import 'package:filmu_nams/providers/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditOfferDialog extends StatefulWidget {
  const EditOfferDialog({
    super.key,
    this.id,
  });

  final String? id;

  @override
  State<EditOfferDialog> createState() => _EditOfferDialogState();
}

class _EditOfferDialogState extends State<EditOfferDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OfferController _offerController = OfferController();

  Style get theme => Style.of(context);

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<PromocodeModel> promocodes = [];
  OfferModel? offerData;
  bool isLoading = true;
  bool isUpdating = false;
  bool hasLinkedPromocode = false;
  String? selectedPromocodeId;

  Uint8List? imageData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<PromocodeModel> allPromocodes = [];
      try {
        final QuerySnapshot querySnapshot =
            await _firestore.collection('promocodes').get();

        allPromocodes = querySnapshot.docs.map((doc) {
          return PromocodeModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      } catch (e) {
        debugPrint('Error loading promocodes: $e');
      }

      OfferModel? offer;
      if (widget.id != null) {
        offer = await _offerController.getOfferById(widget.id!);
        if (offer != null) {
          setState(() {
            titleController.text = offer!.title;
            descriptionController.text = offer.description;
            hasLinkedPromocode = offer.promocode != null;
            selectedPromocodeId = offer.promocode?.id;
          });
        }
      }

      setState(() {
        promocodes = allPromocodes;
        offerData = offer;
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

  Future<void> _saveOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final String title = titleController.text;
      final String description = descriptionController.text;

      DocumentReference? promocodeRef;
      if (hasLinkedPromocode && selectedPromocodeId != null) {
        promocodeRef =
            _firestore.collection('promocodes').doc(selectedPromocodeId);
      }

      bool success;

      if (widget.id == null) {
        final String? newId = await _offerController.addOffer(
          title: title,
          description: description,
          imageData: imageData,
          promocodeRef: promocodeRef,
        );

        success = newId != null;
        if (success && mounted) {
          StylizedDialog.dialog(
            Icons.check_circle_outline,
            context,
            "Veiksmīgi",
            "Piedāvājums pievienots",
          );
        }
      } else {
        success = await _offerController.updateOffer(
          id: widget.id!,
          title: title,
          description: description,
          imageData: imageData,
          currentImageUrl: offerData?.imageUrl,
          promocodeRef: promocodeRef,
        );

        if (success && mounted) {
          StylizedDialog.dialog(
            Icons.check_circle_outline,
            context,
            "Veiksmīgi",
            "Piedāvājums atjaunināts",
          );
        }
      }

      if (success && mounted) {
        Navigator.of(context).pop();
      } else if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās saglabāt piedāvājumu",
        );
      }
    } catch (e) {
      debugPrint('Error saving offer: $e');
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās saglabāt piedāvājumu",
        );
      }
    }

    setState(() {
      isUpdating = false;
    });
  }

  Future<void> _deleteOffer() async {
    try {
      bool confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Dzēst piedāvājumu?", style: theme.headlineMedium),
                content: Text(
                  "Vai tiešām vēlaties dzēst šo piedāvājumu? Šo darbību nevar atsaukt.",
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

        final bool success = await _offerController.deleteOffer(widget.id!);

        if (mounted) {
          if (success) {
            Navigator.of(context).pop();
            StylizedDialog.dialog(
              Icons.check_circle_outline,
              context,
              "Veiksmīgi",
              "Piedāvājums dzēsts",
            );
          } else {
            setState(() {
              isUpdating = false;
            });
            StylizedDialog.dialog(
              Icons.error_outline,
              context,
              "Kļūda",
              "Neizdevās dzēst piedāvājumu",
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error deleting offer: $e');
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās dzēst piedāvājumu",
        );
      }
      setState(() {
        isUpdating = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null && mounted) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => imageData = bytes);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          "Neizdevās izvēlēties attēlu: ${e.toString()}",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 32),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImageSection(),
                              const SizedBox(width: 32),
                              Expanded(child: _buildFormContent()),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildButtonRow(),
                        ],
                      ),
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
          widget.id == null ? "Jauns piedāvājums" : "Rediģēt piedāvājumu",
          style: theme.displayMedium,
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, size: 24),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Container(
          width: 240,
          height: 300,
          decoration: BoxDecoration(
            color: theme.surfaceVariant.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageData != null
              ? Image.memory(imageData!, fit: BoxFit.cover)
              : offerData?.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: offerData!.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: theme.primary,
                          size: 50,
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported,
                                size: 50, color: theme.primary),
                            const SizedBox(height: 8),
                            Text('Attēls nav pieejams',
                                style: theme.bodyMedium),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 50, color: theme.primary),
                          const SizedBox(height: 8),
                          Text('Pievienojiet attēlu', style: theme.bodyMedium),
                        ],
                      ),
                    ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.upload),
          label: Text(offerData?.imageUrl != null
              ? 'Mainīt attēlu'
              : 'Pievienot attēlu'),
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Nosaukums',
            hintText: 'Ievadiet piedāvājuma nosaukumu',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lūdzu ievadiet nosaukumu';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Apraksts',
            hintText: 'Ievadiet piedāvājuma aprakstu',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lūdzu ievadiet aprakstu';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: Text('Piesaistīt promokodu', style: theme.titleMedium),
          value: hasLinkedPromocode,
          onChanged: (value) {
            setState(() {
              hasLinkedPromocode = value;
              if (!value) {
                selectedPromocodeId = null;
              }
            });
          },
          activeColor: theme.primary,
        ),
        if (hasLinkedPromocode) ...[
          const SizedBox(height: 16),
          if (promocodes.isEmpty)
            Text(
                'Nav pieejamu promokodu. Lūdzu, vispirms izveidojiet promokodu.',
                style: theme.bodyMedium.copyWith(color: Colors.orange)),
          if (promocodes.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.surfaceVariant.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.outline),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPromocodeId,
                  isExpanded: true,
                  dropdownColor: theme.surface,
                  style: theme.bodyLarge,
                  icon: Icon(Icons.arrow_drop_down, color: theme.primary),
                  hint: Text('Izvēlieties promokodu',
                      style: theme.bodyLarge
                          .copyWith(color: theme.contrast.withOpacity(0.5))),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPromocodeId = newValue;
                    });
                  },
                  items: promocodes.map<DropdownMenuItem<String>>(
                      (PromocodeModel promocode) {
                    return DropdownMenuItem<String>(
                      value: promocode.id,
                      child: Text(
                          '${promocode.name} ${promocode.percents != null ? '(${promocode.percents}%)' : promocode.amount != null ? '(${promocode.amount} EUR)' : ''}'),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.id != null)
          TextButton(
            onPressed: _deleteOffer,
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
          onPressed: _saveOffer,
          child: Text(widget.id == null ? "Pievienot" : "Saglabāt"),
        ),
      ],
    );
  }
}
