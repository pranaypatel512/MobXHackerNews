import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

import 'hn_api.dart';
import 'news_store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Hacker News"),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Newest'), Tab(text: 'Top')],
            )),
        body: SafeArea(
            child: TabBarView(
                controller: _tabController,
                children: [])) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

class FeedItemsView extends StatelessWidget {
  const FeedItemsView(this.store, this.type, {Key? key}) : super(key: key);

  final HackerNewsStore store;
  final FeedType type;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final future = type == FeedType.latest ? store.latestItemsFuture : store.topItemsFuture;

      if(future==null)
        {
          return const CircularProgressIndicator();
        }

      switch(future.status){
        case FutureStatus.pending :
          return Column(mainAxisAlignment: MainAxisAlignment.center,children: const [
            CircularProgressIndicator(),
            Text("Loading items...")
          ],);
        case FutureStatus.rejected :
          return Row(mainAxisAlignment: MainAxisAlignment.center,children: [
            const Text('Failed to load items.',
              style: TextStyle(color: Colors.red),),
            ElevatedButton(onPressed: _refresh, child: const Text('Tap to try again'))

          ],);

        case FutureStatus.fulfilled :
          final List<FeedItem> items = future.result;
          return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Text(
                        '${item.score}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('- ${item.author}'),
                      onTap: () => store.openUrl(item.url),
                    );
                  }));
      }
    });
  }
  Future _refresh() =>
      (type == FeedType.latest) ? store.fetchLatest() : store.fetchTop();
}
