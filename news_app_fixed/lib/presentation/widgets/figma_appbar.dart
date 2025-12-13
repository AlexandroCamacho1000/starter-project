// presentation/widgets/figma_appbar.dart
import 'package:flutter/material.dart';
import 'package:news_app_fixed/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class FigmaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final VoidCallback? onSearchPressed;
  
  const FigmaAppBar({
    Key? key,
    required this.title,
    this.showSearch = false,
    this.onSearchPressed,
  }) : super(key: key);
  
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: false,
      title: showSearch ? _buildSearchField() : Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppThemes.textBlack,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        if (!showSearch)
          IconButton(
            icon: Icon(Icons.search, color: AppThemes.primaryBlue),
            onPressed: onSearchPressed,
          ),
        SizedBox(width: 8),
      ],
    );
  }
  
  Widget _buildSearchField() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppThemes.cardGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search articles...',
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            color: AppThemes.textGray,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: AppThemes.textGray, size: 20),
          contentPadding: EdgeInsets.only(bottom: 8),
        ),
        style: GoogleFonts.inter(
          fontSize: 16,
          color: AppThemes.textBlack,
        ),
      ),
    );
  }
}