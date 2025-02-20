import 'package:flutter/material.dart';
import 'package:vexana/vexana.dart';
import '../database_file_manager.dart'; // 导入DatabaseFileManager

import './json_place_holder.dart';
import 'model/post.dart';

abstract class JsonPlaceHolderViewModel extends State<JsonPlaceHolder> {
  List<Post> posts = [];
  late INetworkManager<Post> networkManager;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final dbFileManager = DatabaseFileManager();
    dbFileManager.init(); // 初始化数据库

    networkManager = NetworkManager<Post>(
      isEnableLogger: true,
      fileManager: dbFileManager, // 使用自定义的数据库文件管理器
      isEnableTest: true,
      noNetwork: NoNetwork(
        context,
      ),
      options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),
    );
  }

  Future<void> getAllPosts() async {
    changeLoading();
    final response = await networkManager.send<Post, List<Post>>(
      '/posts',
      parseModel: Post(),
      method: RequestType.GET,
      isErrorDialog: true,
    );

    if (response.data is List) {
      posts = response.data ?? [];
    }

    changeLoading();
  }

  void changeLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }
}

class NoNetworkSample extends StatelessWidget {
  const NoNetworkSample({super.key, this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('sample'),
        TextButton(
          onPressed: () {
            onPressed?.call();
            Navigator.of(context).pop();
          },
          child: const Text('data'),
        ),
      ],
    );
  }
}
