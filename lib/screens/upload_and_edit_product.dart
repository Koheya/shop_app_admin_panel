import 'dart:io';

import 'package:admin_app/constants/app_constants.dart';
import 'package:admin_app/constants/my_validators.dart';
import 'package:admin_app/models/product_model.dart';
import 'package:admin_app/screens/loading_manager.dart';
import 'package:admin_app/services/my_app_methods.dart';
import 'package:admin_app/widgets/app_name.dart';
import 'package:admin_app/widgets/sub_title_text.dart';
import 'package:admin_app/widgets/title_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class UploadNewProduct extends StatefulWidget {
  static const String routeName = "upload_new_product";
  const UploadNewProduct({super.key, this.productModel});

  final ProductModel? productModel;
  @override
  State<UploadNewProduct> createState() => _UploadNewProductState();
}

class _UploadNewProductState extends State<UploadNewProduct> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  String? productImageUrl;
  String? _cateroryValue;
  String? productNetworkImage;
  bool isEditing = false;
  bool isLoading = false;
  final auth = FirebaseAuth.instance;
  @override
  void initState() {
    if (widget.productModel != null) {
      isEditing = true;
      productNetworkImage = widget.productModel!.productImage;
      _cateroryValue = widget.productModel!.productCategory;
    }
    _titleController =
        TextEditingController(text: widget.productModel?.productName);
    _priceController =
        TextEditingController(text: widget.productModel?.productPrice);
    _quantityController =
        TextEditingController(text: widget.productModel?.productQuantity);
    _descriptionController =
        TextEditingController(text: widget.productModel?.productDescription);
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void clearForm() {
    _titleController.clear();
    _priceController.clear();
    _quantityController.clear();
    _descriptionController.clear();
    removePickedImage();
  }

  void removePickedImage() {
    setState(() {
      _pickedImage = null;
      productNetworkImage = null;
    });
  }

  Future<void> _editProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null && productNetworkImage == null) {
      MyAppMethods.showErrorOrWarningDialog(
          context: context,
          title: "Please pisck an image",
          msg: "",
          fct: () {});
      return;
    }
    if (_cateroryValue == null) {
      MyAppMethods.showErrorOrWarningDialog(
        context: context,
        title: "Please select a category",
        msg: "",
        fct: () {},
      );
      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          isLoading = true;
        });
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("productsImages")
              .child("${widget.productModel!.productId}.jpg");
          await ref.putFile(File(_pickedImage!.path));
          productImageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productModel!.productId)
            .update({
          "productId": widget.productModel!.productId,
          "productName": _titleController.text,
          "productDescription": _descriptionController.text,
          "productImage": productImageUrl ?? productNetworkImage,
          "createdAt": widget.productModel!.createdAt,
          "productPrice": _priceController.text,
          "productQuantity": _quantityController.text,
          "productCategory": _cateroryValue,
        });
        Fluttertoast.showToast(
          msg: "Product Edited Successfully",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
        // await MyAppMethods.showErrorOrWarningDialog(
        //     context: context,
        //     title: "Success!",
        //     msg: "Clear Form",
        //     btnTitle: "Clear",
        //     isError: false,
        //     onPressed: () {
        //       clearForm();
        //       Navigator.pop(context);
        //     });
      } on FirebaseException catch (error) {
        await MyAppMethods.showErrorOrWarningDialog(
          context: context,
          title: "An Error ocurred ${error.message}",
          msg: "",
          fct: () {},
        );
      } catch (error) {
        await MyAppMethods.showErrorOrWarningDialog(
          context: context,
          title: "An Error ocurred $error",
          msg: "",
          fct: () {},
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null) {
      MyAppMethods.showErrorOrWarningDialog(
        context: context,
        title: "Error!",
        msg: "Please pick an image",
        fct: () {},
      );
      return;
    }
    if (_cateroryValue == null) {
      MyAppMethods.showErrorOrWarningDialog(
        context: context,
        title: "Please select a category",
        msg: "",
        fct: () {},
      );
      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          isLoading = true;
        });
        final productID = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child("productsImages")
            .child("$productID.jpg");
        await ref.putFile(File(_pickedImage!.path));
        productImageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("products")
            .doc(productID)
            .set({
          "productId": productID,
          "productName": _titleController.text,
          "productDescription": _descriptionController.text,
          "productImage": productImageUrl,
          "createdAt": Timestamp.now(),
          "productPrice": _priceController.text,
          "productQuantity": _quantityController.text,
          "productCategory": _cateroryValue,
        });
        Fluttertoast.showToast(
          msg: "Product Uploaded Successfully",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
        await MyAppMethods.showErrorOrWarningDialog(
            context: context,
            title: "Success!",
            msg: "Clear Form",
            fct: () {
              clearForm();
            });
      } on FirebaseException catch (error) {
        await MyAppMethods.showErrorOrWarningDialog(
          context: context,
          title: "An Error ocurred ${error.message}",
          msg: "",
          fct: () {},
        );
      } catch (error) {
        await MyAppMethods.showErrorOrWarningDialog(
          context: context,
          title: "An Error ocurred $error",
          msg: "",
          fct: () {},
        );
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  Future<void> localImagePicker() async {
    final ImagePicker _picker = ImagePicker();
    await MyAppMethods.imagePickerDialog(
      context: context,
      cameraFun: () async {
        _pickedImage = await _picker.pickImage(source: ImageSource.camera);
        setState(() {
          productNetworkImage = null;
        });
      },
      galleryFun: () async {
        _pickedImage = await _picker.pickImage(source: ImageSource.gallery);
        setState(() {
          productNetworkImage = null;
        });
      },
      removeFun: () {
        setState(() {
          _pickedImage = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoadingManager(
      isLoading: isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          bottomSheet: SizedBox(
            height: kBottomNavigationBarHeight + 10,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    label: const TitleTextWidget(
                      label: "Clear",
                      fontSize: 18,
                    ),
                    icon: const Icon(Icons.clear),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (isEditing) {
                        _editProduct();
                      } else {
                        _uploadProduct();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    label: TitleTextWidget(
                      label: isEditing ? "Edit Product" : "upload Product",
                      fontSize: 18,
                    ),
                    icon: const Icon(Icons.upload),
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            title: AppNameText(
                text: isEditing ? "Edit Product" : "Upload New Product"),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // image picker
                if (isEditing && productNetworkImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      productNetworkImage!,
                      height: size.width * 0.4,
                      width: size.width * 0.4 + 10,
                      alignment: Alignment.center,
                    ),
                  ),
                ] else if (_pickedImage == null) ...[
                  SizedBox(
                    height: size.width * 0.4,
                    width: size.width * 0.4 + 10,
                    child: DottedBorder(
                      color: Colors.blue,
                      radius: const Radius.circular(12),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_outlined, size: 80),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () async {
                                localImagePicker();
                              },
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: TitleTextWidget(
                                  label: "Pick Product Image",
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_pickedImage!.path),
                      height: size.width * 0.4,
                      width: size.width * 0.4 + 10,
                      alignment: Alignment.center,
                    ),
                  ),
                ],
                if (_pickedImage != null || productNetworkImage != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          localImagePicker();
                        },
                        child: const Text("Pick another image"),
                      ),
                      TextButton(
                        onPressed: () {
                          removePickedImage();
                        },
                        child: const Text(
                          "Remove image",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      )
                    ],
                  )
                ],

                const SizedBox(height: 20),
                // drop down
                DropdownButton(
                  hint: const Text("Select Category"),
                  value: _cateroryValue,
                  items: AppConstants.categoriesDropdownList,
                  onChanged: (String? value) {
                    setState(() {
                      _cateroryValue = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          key: const ValueKey("Title"),
                          maxLength: 80,
                          minLines: 1,
                          maxLines: 2,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            hintText: "Product Title",
                          ),
                          validator: (value) {
                            return MyValidators.uploadProdTexts(
                              value: value,
                              toBeReturnedString: "Please Enter Product Title",
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Flexible(
                              child: TextFormField(
                                controller: _priceController,
                                key: const ValueKey("Price"),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  )
                                ],
                                decoration: const InputDecoration(
                                  hintText: "Price",
                                  prefix: SubTitleTextWidget(
                                    label: "\$ ",
                                    fontSize: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                                validator: (value) {
                                  return MyValidators.uploadProdTexts(
                                    value: value,
                                    toBeReturnedString:
                                        "Please Enter Product Price",
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 30),
                            Flexible(
                              child: TextFormField(
                                controller: _quantityController,
                                key: const ValueKey("Qty"),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  hintText: "Qty",
                                ),
                                validator: (value) {
                                  return MyValidators.uploadProdTexts(
                                    value: value,
                                    toBeReturnedString:
                                        "Please Enter Product Quantity",
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _descriptionController,
                          key: const ValueKey("Description"),
                          maxLength: 1000,
                          minLines: 5,
                          maxLines: 8,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            hintText: "Product Description",
                          ),
                          validator: (value) {
                            return MyValidators.uploadProdTexts(
                              value: value,
                              toBeReturnedString: "Please Enter Product Title",
                            );
                          },
                        ),
                        const SizedBox(height: kBottomNavigationBarHeight + 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
