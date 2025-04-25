import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/models/user_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class UserCard extends StatefulWidget {
  const UserCard({
    super.key,
    required this.data,
    required this.onEdit,
    required this.isCurrentUser,
  });

  final UserModel data;
  final Function(String) onEdit;
  final bool isCurrentUser;

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Style.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onEdit(widget.data.id),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration:
                  isHovered ? theme.activeCardDecoration : theme.cardDecoration,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildUserInfo(),
                  ),
                  if (widget.isCurrentUser)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: theme.onPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Jūsu profils",
                            style: theme.labelSmall.copyWith(
                              color: theme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 16),
                  _buildRoleBadge(),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.edit, color: theme.primary),
                    onPressed: () => widget.onEdit(widget.data.id),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final size = 70.0;

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: widget.data.profileImageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: widget.data.profileImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                errorWidget: (context, url, error) => _buildAvatarFallback(),
              )
            : _buildAvatarFallback(),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    final theme = Style.of(context);

    return Container(
      color: theme.surfaceVariant,
      child: Icon(
        Icons.person,
        size: 40,
        color: theme.primary,
      ),
    );
  }

  Widget _buildUserInfo() {
    final theme = Style.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.data.name,
            style: theme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.email,
                  size: 14, color: theme.primary.withOpacity(0.7)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.data.email,
                  style: theme.bodyMedium
                      .copyWith(color: theme.contrast.withOpacity(0.7)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 14, color: theme.primary.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                "Reģistrēts: ${_formatDate(widget.data.createdAt.toDate())}",
                style: theme.bodySmall
                    .copyWith(color: theme.contrast.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge() {
    final theme = Style.of(context);
    final isAdmin = widget.data.role == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAdmin
            ? theme.primary.withOpacity(0.2)
            : theme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAdmin ? theme.primary.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            size: 16,
            color: isAdmin ? theme.primary : theme.contrast.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            isAdmin ? "Administrators" : "Lietotājs",
            style: theme.labelMedium.copyWith(
              color: isAdmin ? theme.primary : theme.contrast.withOpacity(0.7),
              fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
}
