import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String activeTab;
  final VoidCallback? onEntrarTap;
  final VoidCallback? onBackTap;

  const CustomNavBar({
    super.key,
    this.showBackButton = false,
    this.activeTab = 'Início',
    this.onEntrarTap,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 12 : 22,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(color: Colors.cyan.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (showBackButton) ...[
              IconButton(
                onPressed: onBackTap,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white70,
                ),
                tooltip: "Voltar",
              ),
              const SizedBox(width: 8),
            ],

            // Logo
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [Color(0xff22d3ee), Color(0xff34d399)],
                ).createShader(bounds);
              },
              child: Text(
                "Koavy",
                style: TextStyle(
                  fontSize: isMobile ? 24 : 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),

            const Spacer(),

            // Menu Items (only on Desktop)
            if (!isMobile) ...[
              _buildNavItem("Início", activeTab == "Início"),
              const SizedBox(width: 40),
              _buildNavItem("Benefícios", activeTab == "Benefícios"),
              const SizedBox(width: 40),
              _buildNavItem("Sobre", activeTab == "Sobre"),
              const SizedBox(width: 60),
            ],

            // Entrar Button
            if (onEntrarTap != null)
              InkWell(
                onTap: onEntrarTap,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 28,
                    vertical: isMobile ? 10 : 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [Color(0xff22d3ee), Color(0xff34d399)],
                    ),
                  ),
                  child: Text(
                    "Entrar",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String text, bool active) {
    return Text(
      text,
      style: TextStyle(
        color: active ? Colors.cyanAccent : Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
