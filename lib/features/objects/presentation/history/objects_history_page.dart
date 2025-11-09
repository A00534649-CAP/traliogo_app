import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../api/models/object_models.dart';
import 'objects_history_controller.dart';

class ObjectsHistoryPage extends ConsumerStatefulWidget {
  const ObjectsHistoryPage({super.key});

  @override
  ConsumerState<ObjectsHistoryPage> createState() => _ObjectsHistoryPageState();
}

class _ObjectsHistoryPageState extends ConsumerState<ObjectsHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(objectsHistoryControllerProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(objectsHistoryControllerProvider);
    final historyController = ref.read(objectsHistoryControllerProvider.notifier);

    ref.listen(objectsHistoryControllerProvider, (previous, next) {
      if (next.state == ObjectsHistoryState.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Objetos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => historyController.loadHistory(),
          ),
        ],
      ),
      body: _buildBody(historyState, historyController),
    );
  }

  Widget _buildBody(ObjectsHistoryStateData historyState, ObjectsHistoryController historyController) {
    switch (historyState.state) {
      case ObjectsHistoryState.initial:
      case ObjectsHistoryState.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
              ),
              SizedBox(height: 16),
              Text('Cargando historial...', style: AppTextStyles.body1),
            ],
          ),
        );

      case ObjectsHistoryState.loaded:
        if (historyState.objects.isEmpty) {
          return _buildEmptyState();
        }
        return _buildObjectsList(historyState.objects, historyController);

      case ObjectsHistoryState.error:
        return _buildErrorState(historyController);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay objetos reconocidos',
            style: AppTextStyles.headline2,
          ),
          const SizedBox(height: 8),
          const Text(
            'Usa la cámara para reconocer objetos y aparecerán aquí',
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Reconocer Objeto'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ObjectsHistoryController historyController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar historial',
            style: AppTextStyles.headline2,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => historyController.loadHistory(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectsList(List<ObjectOut> objects, ObjectsHistoryController historyController) {
    return RefreshIndicator(
      onRefresh: () => historyController.loadHistory(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: objects.length,
        itemBuilder: (context, index) {
          final object = objects[index];
          return _buildObjectCard(object, historyController);
        },
      ),
    );
  }

  Widget _buildObjectCard(ObjectOut object, ObjectsHistoryController historyController) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primaryTeal,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        object.objectName,
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confianza: ${(object.confidence * 100).toStringAsFixed(1)}%',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(object.createdAt),
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(context, object, historyController);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (object.imageUrl != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ObjectOut object,
    ObjectsHistoryController historyController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar objeto'),
        content: Text('¿Estás seguro de que quieres eliminar "${object.objectName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              historyController.deleteObject(object.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} días atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutos atrás';
    } else {
      return 'Ahora mismo';
    }
  }
}