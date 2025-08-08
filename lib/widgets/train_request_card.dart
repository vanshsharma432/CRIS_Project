import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/train_request_model.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../constants/strings.dart';
import '../widgets/train_request_card_parts.dart';
import '../widgets/edit_options_widget.dart'; // Make sure this exists
import '../services/API.dart';

class TrainRequestCard extends StatelessWidget {
  final TrainRequest request;
  final ValueChanged<bool?> onSelectionChanged;
  final ValueChanged<int> onPriorityChanged;
  final VoidCallback onRejected;

  const TrainRequestCard({
    super.key,
    required this.request,
    required this.onSelectionChanged,
    required this.onPriorityChanged,
    required this.onRejected,
  });

  String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  String formatDateTime(DateTime date) =>
      DateFormat('dd MMM yyyy hh:mm a').format(date);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final statusColor = request.currentStatus.toLowerCase().contains('cnf')
        ? AColors.primary
        : AColors.yellow;

    return Card(
      elevation: isDesktop ? 2 : 3,
      margin: EdgeInsets.symmetric(
        vertical: isDesktop ? 4 : 10,
        horizontal: isDesktop ? 16 : 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 16),
        side: isDesktop
            ? BorderSide(color: Colors.grey.shade200, width: 1)
            : BorderSide.none,
      ),
      color: AColors.offWhite,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 12 : 16),
        child: isDesktop
            ? _buildDesktopLayout(context , statusColor)
            : _buildMobileLayout(statusColor),
      ),
    );
  }

  // ---------------- Desktop Layout ----------------
  // ---------------- Desktop Layout ----------------
  Widget _buildDesktopLayout(BuildContext context, Color   statusColor) {
    return Column(
      children: [
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(1),     // PNR + Journey Date
            1: FixedColumnWidth(120),  // Start Date
            2: FlexColumnWidth(1),     // Train No + Route
            3: FixedColumnWidth(80),   // Class ✅ (New)
            4: FlexColumnWidth(1),     // Division + Zone
            5: FixedColumnWidth(160),  // Passenger Counts
            6: FlexColumnWidth(2),     // Requested By
            7: FixedColumnWidth(100),  // Status
            8: FixedColumnWidth(150),  // Edit
          },

          children: [
            TableRow(children: [
              // 1. PNR + Journey Date
              // TableCellText("${request.pnr} (${formatDate(request.trainJourneyDate)})"),
                  InkWell(
                    onTap: () {
                      debugPrint("PNR clicked: ${request.pnr}");
                    },
                    child: TableCellText(
                      "${request.pnr}\n(${formatDate(request.trainJourneyDate)})",
                      color: AColors.primary,
                      bold: true,
                    ),
                  ),



              // 2. Start Date
              TableCellText(formatDate(request.trainStartDate)),

              // 3. Train No + Route
              TableCellText("${request.trainNo}\n( ${request.sourceStation} )"),

              TableCellText(request.seatClass.toUpperCase()),


              // 4. Division + Zone
              TableCellText("${request.division}\n(${request.zone})"),

              // 5. Passenger Counts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  PassengerMetric(AStrings.total, request.totalPassengers.toString()),
                  PassengerMetric(AStrings.requested, request.requestedPassengers.toString()),
                  PassengerMetric(AStrings.accepted, request.acceptedPassengers.toString()),
                ],
              ),

              // 6. Requested By + Requested On
               GestureDetector(
                onTap: () async {
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final response = await MRApiService.fetchEQRequest("EQ0000000010");
                    Navigator.pop(context); // Close loading

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('EQ Request Info'),
                        content: Text(response?['message'] ?? 'No data available'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context); // Close loading
                    
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Error'),
                        content: Text('Failed to load data. Please try again.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: TableCellText("${request.requestedBy} (${request.eqRequestNo})\n (${formatDateTime(request.requestedOn)})"),
              ),


              // 7. Status
              TableCellText(request.currentStatus.toUpperCase(), color: statusColor),

              // 8. Edit Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: EditOptionsWidget(
                  initialPriority: request.priority,
                  eqRequestNo: request.eqRequestNo, // Add this line
                  onPriorityChanged: onPriorityChanged,
                  onRejected: onRejected,
                ),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                "${AStrings.remarksPrefix}${request.remarksByRailways.isNotEmpty ? request.remarksByRailways : AStrings.noRemarks}",
                style: ATextStyles.footerHint,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                Text(
                  "${AStrings.lastUpdated}: ${formatDateTime(request.lastUpdated)}",
                  style: ATextStyles.footerHint,
                ),
                const SizedBox(width: 16),
              ],
            )
          ],
        ),
      ],
    );
  }



  // ---------------- Mobile Layout ----------------
  Widget _buildMobileLayout(Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request.currentStatus.toUpperCase(),
          style: ATextStyles.cardTitle.copyWith(color: statusColor),
        ),
        const SizedBox(height: 12),
        IconTextRow(
          icon: Icons.train,
          label: "",
          value: "${request.trainNo} (${request.sourceStation} → ${request.destination})",
          iconColor: AColors.secondary,
        ),
        const SizedBox(height: 8),
        IconTextRow(
          icon: Icons.calendar_today,
          label: "",
          value: "${AStrings.pnrLabel} ${request.pnr}\n(${formatDate(request.trainJourneyDate)})",
          iconColor: AColors.gray,
        ),
        const SizedBox(height: 8),
        IconTextRow(
          icon: Icons.event_available,
          label: "",
          value: "${AStrings.startDate}: ${formatDate(request.trainStartDate)}",
          iconColor: AColors.gray,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.group, size: 18, color: AColors.primary),
            const SizedBox(width: 4),
            Text("${AStrings.passengers}: ", style: ATextStyles.bodyBold),
            Flexible(
              child: Text(
                "${AStrings.total}: ${request.totalPassengers} | "
                    "${AStrings.requested}: ${request.requestedPassengers} | "
                    "${AStrings.accepted}: ${request.acceptedPassengers}",
                style: ATextStyles.bodySmall,
              ),
            ),
          ],
        ),
        const Divider(height: 24),
        IconTextRow(
          icon: Icons.person,
          label: "",
          value: "${AStrings.reqByShort}${request.requestedBy} (${formatDateTime(request.requestedOn)})",
          iconColor: AColors.secondary,
        ),
        const SizedBox(height: 6, width: 20,),
        IconTextRow(
          icon: Icons.account_tree_outlined,
          label: AStrings.divZoneShort,
          value: "${request.division} (${request.zone})",
          iconColor: AColors.secondary,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.note_alt, size: 18, color: AColors.gray),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                "${AStrings.remarksPrefix}${request.remarksByRailways.isNotEmpty ? request.remarksByRailways : AStrings.noRemarks}",
                style: ATextStyles.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${AStrings.lastUpdated}: ${formatDateTime(request.lastUpdated)}",
              style: ATextStyles.caption,
            ),
            EditOptionsWidget(
              initialPriority: request.priority,
              eqRequestNo: request.eqRequestNo,
              onPriorityChanged: onPriorityChanged,
              onRejected: onRejected,
            ),
          ],
        ),
      ],
    );
  }
}
