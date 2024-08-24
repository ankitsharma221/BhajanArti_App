import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class WallpaperPage extends StatefulWidget {
  @override
  _WallpaperPageState createState() => _WallpaperPageState();
}

class _WallpaperPageState extends State<WallpaperPage>
    with AutomaticKeepAliveClientMixin {
  final cacheManager = DefaultCacheManager();
  late Future<List<ImageModel>> _imagesFuture;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  List<ImageModel> _allImages = [];
  bool _hasMoreImages = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _imagesFuture = fetchImages();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMoreImages();
    }
  }

  @override
  bool get wantKeepAlive => true;

  Future<List<ImageModel>> fetchImages(
      {int page = 1, int limit = 20, int retryCount = 3}) async {
    try {
      final response = await http
          .get(Uri.parse(
              'https://bhajanapi.vercel.app/wallpapers?page=$page&limit=$limit'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> wallpapers = data['wallpapers'];
        int totalPages = data['totalPages'];

        _hasMoreImages = page < totalPages;

        List<ImageModel> images =
            wallpapers.map((item) => ImageModel.fromJson(item)).toList();
        images.shuffle(); // Shuffle the images
        return images;
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      if (retryCount > 0) {
        await Future.delayed(Duration(seconds: 2));
        return fetchImages(
            page: page, limit: limit, retryCount: retryCount - 1);
      } else {
        throw Exception('Network error: Unable to fetch images');
      }
    }
  }

  Future<Uint8List> _getCachedOrDownloadImage(String imageUrl) async {
    final Uri uri = Uri.parse(imageUrl);
    final FileInfo? fileInfo =
        await DefaultCacheManager().getFileFromCache(uri.toString());

    if (fileInfo != null) {
      return await fileInfo.file.readAsBytes();
    } else {
      final http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        final Uint8List imageData = response.bodyBytes;
        await DefaultCacheManager().putFile(uri.toString(), imageData);
        return imageData;
      } else {
        throw Exception('Failed to load image');
      }
    }
  }

  Future<void> _refreshImages() async {
    setState(() {
      _currentPage = 1;
      _allImages.clear();
      _hasMoreImages = true;
      _imagesFuture = fetchImages();
    });
  }

  Future<void> _loadMoreImages() async {
    if (!_isLoadingMore && _hasMoreImages) {
      setState(() {
        _isLoadingMore = true;
      });
      _currentPage++;
      try {
        List<ImageModel> newImages = await fetchImages(page: _currentPage);
        setState(() {
          _allImages.addAll(newImages);
          _isLoadingMore = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingMore = false;
        });
        _showSnackBar('Failed to load more images. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshImages,
        child: FutureBuilder<List<ImageModel>>(
          future: _imagesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _allImages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitFoldingCube(
                      color: Colors.orange,
                      size: 50.0,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Loading Wallpapers...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Oops! Something went wrong.',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshImages,
                      child: Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              _allImages = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  controller: _scrollController,
                  itemCount: _allImages.length + (_hasMoreImages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _allImages.length) {
                      return _buildImageCard(_allImages[index]);
                    } else if (_hasMoreImages) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              );
            } else {
              return Center(
                child: Text(
                  'No images found',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildImageCard(ImageModel imageModel) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: FutureBuilder<Uint8List>(
              future: _getCachedOrDownloadImage(imageModel.imageUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AspectRatio(
                    aspectRatio: 1,
                    child: Center(
                      child: SpinKitFadingCircle(
                        color: Colors.orange,
                        size: 30.0,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return AspectRatio(
                    aspectRatio: 1,
                    child: Center(
                      child: Icon(Icons.error, color: Colors.red, size: 30),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FullScreenImage(imageUrl: imageModel.imageUrl),
                        ),
                      );
                    },
                    child: Hero(
                      tag: imageModel.id,
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.download,
                    label: 'Download',
                    onPressed: () => _saveImageToDevice(imageModel.imageUrl),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    }

    if (await Permission.photos.request().isGranted) {
      return true;
    }

    if (Theme.of(context).platform == TargetPlatform.android) {
      bool status = await Permission.manageExternalStorage.status.isGranted;
      if (!status) {
        status = await Permission.manageExternalStorage.request().isGranted;
      }
      return status;
    }

    return false;
  }

  Future<void> _saveImageToDevice(String imageUrl) async {
    if (await _requestPermissions()) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final result = await ImageGallerySaver.saveImage(response.bodyBytes);
          if (result['isSuccess']) {
            _showSnackBar('चित्र गैलरी में सेव हो गया है');
          } else {
            throw Exception('चित्र सेव करने में विफल');
          }
        } else {
          throw Exception('चित्र सेव करने में विफल');
        }
      } catch (e) {
        _showSnackBar('Unable to save image. Please try again.');
      }
    } else {
      _showSnackBar('चित्र सेव करने की अनुमति नहीं मिली');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class ImageModel {
  final String id;
  final String imageName;
  final String imageUrl;

  ImageModel(
      {required this.id, required this.imageName, required this.imageUrl});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['_id'],
      imageName: json['imageName'],
      imageUrl: json['imageUrl'],
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  Future<bool> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    }

    if (await Permission.photos.request().isGranted) {
      return true;
    }

    if (TargetPlatform.android == defaultTargetPlatform) {
      bool status = await Permission.manageExternalStorage.status.isGranted;
      if (!status) {
        status = await Permission.manageExternalStorage.request().isGranted;
      }
      return status;
    }

    return false;
  }

  Future<void> _saveImageToDevice(BuildContext context) async {
    if (await _requestPermissions()) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final result = await ImageGallerySaver.saveImage(response.bodyBytes);
          if (result['isSuccess']) {
            _showSnackBar(context, 'चित्र गैलरी में सेव हो गया है');
          } else {
            throw Exception('चित्र सेव करने में विफल');
          }
        } else {
          throw Exception('चित्र सेव करने में विफल');
        }
      } catch (e) {
        _showSnackBar(context, 'Unable to save image. Please try again.');
      }
    } else {
      _showSnackBar(context, 'चित्र सेव करने की अनुमति नहीं मिली');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            Center(
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveImageToDevice(context),
        child: Icon(Icons.download),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
