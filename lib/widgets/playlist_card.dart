import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../utils/constants.dart';

class PlaylistCard extends StatefulWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const PlaylistCard({
    Key? key,
    required this.playlist,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  }) : super(key: key);

  @override
  State<PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<PlaylistCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.playlist_play,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        title: Text(
          widget.playlist.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${widget.playlist.songIds.length} songs',
          style: TextStyle(color: AppColors.grey, fontSize: 12),
        ),
        trailing: PopupMenuButton(
          color: AppColors.surface,
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              onTap: widget.onTap,
              child: Row(
                children: [
                  const Icon(
                    Icons.play_arrow,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('Play', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: widget.onRename,
              child: Row(
                children: [
                  const Icon(Icons.edit, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text('Rename', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: widget.onDelete,
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  const Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert, color: AppColors.grey),
        ),
        onTap: widget.onTap,
      ),
    );
  }
}
