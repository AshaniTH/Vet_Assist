import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_assist/e_clinic_book/weight/weight_model.dart';
import 'package:vet_assist/e_clinic_book/weight/weight_service.dart';
import 'package:vet_assist/e_clinic_book/weight/weight_chart.dart';
import 'package:vet_assist/e_clinic_book/weight/weight_form.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';
import 'package:intl/intl.dart';

class WeightListPage extends StatefulWidget {
  final Pet pet;

  const WeightListPage({super.key, required this.pet});

  @override
  State<WeightListPage> createState() => _WeightListPageState();
}

class _WeightListPageState extends State<WeightListPage> {
  late Future<List<WeightEntry>> _chartDataFuture;

  @override
  void initState() {
    super.initState();
    _chartDataFuture = Provider.of<WeightService>(
      context,
      listen: false,
    ).getWeightEntriesForChart(widget.pet.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.pet.name}'s Weight Tracker"),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeightFormPage(pet: widget.pet),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<List<WeightEntry>>(
            future: _chartDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error loading chart: ${snapshot.error}'),
                );
              }
              return Card(
                margin: const EdgeInsets.all(16),
                color: const Color(0xFF219899),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: WeightChart(entries: snapshot.data ?? []),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<List<WeightEntry>>(
              stream: Provider.of<WeightService>(
                context,
              ).getWeightEntries(widget.pet.id!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final entries = snapshot.data ?? [];

                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.monitor_weight,
                          size: 60,
                          color: Color(0xFF219899),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No weight entries yet',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        WeightFormPage(pet: widget.pet),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF219899),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Add First Weight Entry'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _WeightEntryCard(pet: widget.pet, entry: entry);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightEntryCard extends StatelessWidget {
  final Pet pet;
  final WeightEntry entry;

  const _WeightEntryCard({required this.pet, required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final weightService = Provider.of<WeightService>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${entry.weight} kg',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF219899),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: const Color(0xFF219899),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    WeightFormPage(pet: pet, entry: entry),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      onPressed:
                          () => _showDeleteDialog(context, weightService),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateFormat.format(entry.date),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (entry.bodyCondition != null) ...[
              const SizedBox(height: 8),
              Text(
                'Body Condition: ${entry.bodyCondition}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${entry.notes}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WeightService service,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Weight Entry?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to delete this weight entry?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await service.deleteWeightEntry(pet.id!, entry.id!);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Weight entry has been deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete weight entry: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
