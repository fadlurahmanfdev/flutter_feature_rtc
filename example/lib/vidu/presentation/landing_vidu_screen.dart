import 'package:example/main.dart';
import 'package:example/vidu/data/repository/vidu_datasource_repository.dart';
import 'package:example/vidu/presentation/bloc/vidu_bloc.dart';
import 'package:example/vidu/presentation/vidu_video_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LandingViduScreen extends StatelessWidget {
  const LandingViduScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return ViduBloc(
          datasourceRepositoryImpl: ViduDatasourceRepositoryImpl(
            dio: viduDio,
          ),
        );
      },
      child: const LandingViduLayout(),
    );
  }
}

class LandingViduLayout extends StatefulWidget {
  const LandingViduLayout({super.key});

  @override
  State<LandingViduLayout> createState() => _LandingViduLayoutState();
}

class _LandingViduLayoutState extends State<LandingViduLayout> {
  late ViduBloc viduBloc;

  String sessionId = 'extensive-plum-weasel';
  String basicAuthToken = 'T1BFTlZJRFVBUFA6UWtGT1MwMUJVekl3TWpJSw==';

  @override
  void initState() {
    super.initState();
    viduBloc = BlocProvider.of<ViduBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ViduBloc, ViduState>(
          listenWhen: (previous, current) => previous.createConnectionStateState != current.createConnectionStateState,
          listener: (context, state) {
            final connectionState = state.createConnectionStateState;
            if (connectionState is CreateConnectionStateSuccess) {
              print("masuk connection response: ${connectionState.connection.toJson()}");
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ViduVideoCallScreen(
                        sessionId: sessionId,
                        sessionToken: connectionState.connection.token ?? '',
                      )));
            } else if (connectionState is CreateConnectionStateFailed) {
              print("failed connectionState: ${connectionState.exception.toString()}");
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Join to existing room'),
        ),
        body: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () async {
                  viduBloc.add(
                    ViduEvent.createConnection(
                      sessionId: sessionId,
                      basicAuthToken: basicAuthToken,
                    ),
                  );
                },
                child: const Text('Create Connection'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
