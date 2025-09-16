import 'dart:io';
import 'package:clean_metadata/models/consts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: primaryColor,
              surfaceTintColor: primaryColor,
              title: const Text(
                'MaTaDaTa Reader & Clearer',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (vm.selectedImage != null)
                    Image.file(File(vm.selectedImage!.path), height: 200),
                  const SizedBox(height: 20),
                  if (vm.isLoading) const CircularProgressIndicator(),
                  if (vm.error != null)
                    Text(vm.error!, style: const TextStyle(color: Colors.red)),
                  Text(
                    vm.metadata,
                    maxLines: 300,
                    softWrap: true,
                    textScaler: const TextScaler.linear(1.0),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (vm.clearedImagePath != null)
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text('Cleared image saved at:'),
                        Text(
                          vm.clearedImagePath!,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 26),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.share, color: primaryColor),
                          label: const Text(
                            'Share Cleared Image',
                            style: TextStyle(color: primaryColor),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            surfaceTintColor: secondaryColor,
                          ),
                          onPressed: vm.shareClearedImage,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'pickImage',
                  onPressed: vm.isLoading ? null : () => vm.pickImage(context),
                  tooltip: 'Pick Image',
                  backgroundColor: primaryColor,
                  child: const Icon(Icons.image, color: Colors.white),
                ),
                const SizedBox(height: 10),
                if (vm.selectedImage != null)
                  FloatingActionButton(
                    heroTag: 'clearMetadata',
                    onPressed: vm.isLoading
                        ? null
                        : () => vm.clearAndSaveMetadata(context),
                    tooltip: 'Clear Metadata & Save',
                    backgroundColor: primaryColor,
                    child: const Icon(Icons.download, color: Colors.white),
                  ),
                if (vm.selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: FloatingActionButton(
                      heroTag: 'reset',
                      onPressed: vm.isLoading ? null : vm.reset,
                      tooltip: 'Reset',
                      backgroundColor: Colors.grey,
                      child: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
