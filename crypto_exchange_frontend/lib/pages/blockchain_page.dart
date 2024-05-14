import 'package:crypto_exchange_frontend/models/models.dart';
import 'package:crypto_exchange_frontend/services/services.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class BlockchainPage extends StatefulWidget {
  const BlockchainPage({super.key});

  @override
  State<BlockchainPage> createState() => _BlockchainPageState();
}

class _BlockchainPageState extends State<BlockchainPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<BlockService>(context, listen: false).getBlockchain();
    });
  }

  @override
  Widget build(BuildContext context) {
    final blockService = Provider.of<BlockService>(context);

    if (blockService.isLoadingBlockchain) {
      return ScaffoldPage(
        header: const PageHeader(title: Text('Blockchain')),
        content: Center(
          child: ProgressRing(activeColor: Colors.green),
        ),
      );
    }

    return ScaffoldPage(
      header: const PageHeader(title: Text('Blockchain')),
      content: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
        child: Stack(
          children: [
            const SizedBox.expand(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox.expand(
                      child: ListOfBlocks(),
                    ),
                  ),
                ],
              ),
            ),
            if (Provider.of<BlockService>(context).verificationState == 0)
              const Positioned(
                bottom: 10,
                right: 10,
                child: VerifyBlockchainButton(),
              ),
            if (Provider.of<BlockService>(context).verificationState == 1)
              const Positioned(
                bottom: 0,
                right: 0,
                child: ProcessingBlockchainVerification(),
              ),
            if (Provider.of<BlockService>(context).verificationState == 2)
              Positioned(
                bottom: 0,
                right: 0,
                child: InfoBarMessage(
                  success: true,
                  message: blockService.verificationMessage,
                ),
              ),
            if (Provider.of<BlockService>(context).verificationState == 3)
              Positioned(
                bottom: 0,
                right: 0,
                child: InfoBarMessage(
                  success: false,
                  message: blockService.verificationMessage,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class VerifyBlockchainButton extends StatelessWidget {
  const VerifyBlockchainButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FilledButton(
        style: ButtonStyle(
          backgroundColor: ButtonState.all<Color>(Colors.green),
          shape: ButtonState.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        onPressed: () async {
          await Provider.of<BlockService>(context, listen: false)
              .verifyBlockchain();
        },
        child: const Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Icon(
                FluentIcons.skype_check,
                size: 30,
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 90,
                child: Text(
                  'Verificar blockchain',
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'RobotoMono',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProcessingBlockchainVerification extends StatelessWidget {
  const ProcessingBlockchainVerification({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 60,
      child: Card(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const Text(
                'Verificando blockchain...',
                style: TextStyle(fontSize: 14, fontFamily: 'RobotoMono'),
              ),
              Expanded(child: Container()),
              ProgressBar(activeColor: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoBarMessage extends StatelessWidget {
  const InfoBarMessage({
    required this.success,
    required this.message,
    super.key,
  });

  final bool success;
  final String message;

  @override
  Widget build(BuildContext context) {
    if (success) {
      return InfoBar(
        title: const Text('Éxito'),
        content: Text(message),
        onClose: () {
          Provider.of<BlockService>(context, listen: false)
              .setInitialVerificationState();
        },
        severity: InfoBarSeverity.success,
      );
    } else {
      return InfoBar(
        title: const Text('Error'),
        content: Text(message),
        onClose: () {
          Provider.of<BlockService>(context, listen: false)
              .setInitialVerificationState();
        },
        severity: InfoBarSeverity.error,
      );
    }
  }
}

class ListOfBlocks extends StatelessWidget {
  const ListOfBlocks({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final blockService = Provider.of<BlockService>(context);

    return ListView.builder(
      itemCount: blockService.blocks.length,
      itemBuilder: (context, index) {
        return BlockListTile(
          block: blockService.blocks[index],
          isFirst: index == 0,
          isLast: index == blockService.blocks.length - 1,
        );
      },
    );
  }
}

class BlockListTile extends StatelessWidget {
  const BlockListTile({
    required this.block,
    required this.isFirst,
    required this.isLast,
    super.key,
  });

  final BlockModel block;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, bottom: 7, right: 20),
      child: Row(
        children: [
          Expanded(
            child: Card(
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlockField(
                          title: 'Id',
                          content: block.id,
                          titleWidth: 155,
                        ),
                        BlockField(
                          title: 'Índice',
                          content: block.index.toString(),
                          titleWidth: 155,
                        ),
                        BlockField(
                          title: 'Hash anterior',
                          content: block.previousHash,
                          titleWidth: 155,
                        ),
                        BlockField(
                          title: 'Prueba de trabajo',
                          content: block.proof.toString(),
                          titleWidth: 155,
                        ),
                        BlockField(
                          title: 'Fecha',
                          content: block.timestamp.toIso8601String(),
                          titleWidth: 155,
                        ),
                        BlockField(
                          title: 'Minero',
                          content: block.miner,
                          titleWidth: 155,
                        ),
                        BlockField(
                          title: 'Firma',
                          content: block.signature,
                          titleWidth: 155,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlockField(
                          title: 'Emisario',
                          content: (block.transaction.from == null)
                              ? 'Null'
                              : block.transaction.from!,
                          titleWidth: 80,
                        ),
                        BlockField(
                          title: 'Receptor',
                          content: (block.transaction.to == null)
                              ? 'Null'
                              : block.transaction.to!,
                          titleWidth: 80,
                        ),
                        BlockField(
                          title: 'Cantidad',
                          content: (block.transaction.amount == null)
                              ? 'Null'
                              : block.transaction.amount.toString(),
                          titleWidth: 80,
                        ),
                        BlockField(
                          title: 'Comisión',
                          content: (block.transaction.fee == null)
                              ? 'Null'
                              : block.transaction.fee.toString(),
                          titleWidth: 80,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            children: [
              if (!isFirst)
                Container(
                  height: 15,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    color: Colors.green,
                  ),
                ),
              if (!isFirst)
                Container(color: Colors.green, width: 7.5, height: 45),
              if (isFirst) const SizedBox(height: 60),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.green,
                ),
              ),
              if (!isLast)
                Container(color: Colors.green, width: 7.5, height: 45),
              if (!isLast)
                Container(
                  height: 15,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    color: Colors.green,
                  ),
                ),
              if (isLast) const SizedBox(height: 60),
            ],
          ),
        ],
      ),
    );
  }
}

class BlockField extends StatelessWidget {
  const BlockField({
    required this.title,
    required this.content,
    required this.titleWidth,
    super.key,
  });

  final String title;
  final String content;
  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: titleWidth,
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono',
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            content,
            maxLines: 1,
            style: const TextStyle(fontFamily: 'RobotoMono'),
          ),
        ),
      ],
    );
  }
}
