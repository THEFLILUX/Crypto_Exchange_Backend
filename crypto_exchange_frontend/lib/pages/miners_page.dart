import 'package:crypto_exchange_frontend/models/models.dart';
import 'package:crypto_exchange_frontend/services/services.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class MinersPage extends StatefulWidget {
  const MinersPage({super.key});

  @override
  State<MinersPage> createState() => _MinersPageState();
}

class _MinersPageState extends State<MinersPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<BlockService>(context, listen: false).getMiners();
    });
  }

  @override
  Widget build(BuildContext context) {
    final blockService = Provider.of<BlockService>(context);

    if (blockService.isLoadingMiners) {
      return ScaffoldPage(
        header: const PageHeader(title: Text('Mineros')),
        content: Center(
          child: ProgressRing(activeColor: Colors.green),
        ),
      );
    }

    return const ScaffoldPage(
      header: PageHeader(title: Text('Mineros')),
      content: Padding(
        padding: EdgeInsets.only(left: 25, right: 25, bottom: 25),
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox.expand(
                  child: ListOfMiners(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListOfMiners extends StatelessWidget {
  const ListOfMiners({super.key});

  @override
  Widget build(BuildContext context) {
    final blockService = Provider.of<BlockService>(context);

    return ListView.builder(
      itemCount: blockService.miners.length,
      itemBuilder: (context, index) {
        final miner = blockService.miners[index];
        return MinerListTile(miner: miner);
      },
    );
  }
}

class MinerListTile extends StatelessWidget {
  const MinerListTile({
    required this.miner,
    super.key,
  });

  final MinerModel miner;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Card(
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(FluentIcons.server, size: 75),
                        const SizedBox(height: 10),
                        SelectableText(
                          miner.index.toString(),
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nombre',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SelectableText(
                          miner.name,
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  MinerField(
                                    icon: FluentIcons.virtual_network,
                                    title: 'Bloques minados',
                                    content: miner.blocksMined.toString(),
                                  ),
                                  MinerField(
                                    icon: FluentIcons.money,
                                    title: 'Cantidad minada',
                                    content:
                                        miner.totalCoins.toStringAsFixed(3),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  MinerField(
                                    icon: FluentIcons.filter_settings,
                                    title: 'Trabajo total',
                                    content: miner.work.toString(),
                                  ),
                                  MinerField(
                                    icon: FluentIcons.calculator_percentage,
                                    title: 'Porcentaje de trabajo',
                                    content:
                                        miner.workPercent.toStringAsFixed(3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MinerField extends StatelessWidget {
  const MinerField({
    required this.icon,
    required this.title,
    required this.content,
    super.key,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 60,
          child: Icon(
            icon,
            size: 40,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SelectableText(
                content,
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 150),
      ],
    );
  }
}
