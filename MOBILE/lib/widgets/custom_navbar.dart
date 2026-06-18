import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String activeTab;
  final VoidCallback? onEntrarTap;
  final VoidCallback? onCadastroTap;
  final VoidCallback? onComecarTap;
  final Function(String)? onTabTap;
  final VoidCallback? onBackTap;

  const CustomNavBar({
    super.key,
    this.showBackButton = false,
    this.activeTab = 'Início',
    this.onEntrarTap,
    this.onCadastroTap,
    this.onComecarTap,
    this.onTabTap,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1280;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
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
                onPressed: onBackTap ?? () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white70,
                ),
                tooltip: "Voltar",
              ),
              const SizedBox(width: 8),
            ],

            // Logo
            GestureDetector(
              onTap: () {
                if (onTabTap != null) {
                  onTabTap!("Início");
                } else {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              child: ShaderMask(
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
            ),

            const Spacer(),

            // Menu Items (only on Desktop)
            if (!isMobile) ...[
              _buildNavItem("Início", activeTab == "Início"),
              const SizedBox(width: 24),
              _buildNavItem("Sobre", activeTab == "Sobre"),
              const SizedBox(width: 24),
              _buildNavItem("Funcionalidades", activeTab == "Funcionalidades"),
              const SizedBox(width: 24),
              _buildNavItem("Monitoramento", activeTab == "Monitoramento"),
              const SizedBox(width: 24),
              _buildNavItem("Suporte", activeTab == "Suporte"),
              const SizedBox(width: 30),
            ],

            // Auth Buttons
            if (isMobile) ...[
              // No mobile, apenas um botão compacto se callbacks fornecidos
              if (onEntrarTap != null)
                IconButton(
                  icon: const Icon(Icons.login, color: Color(0xff00f2ff)),
                  onPressed: onEntrarTap,
                  tooltip: "Login",
                ),
            ] else ...[
              if (onEntrarTap != null) ...[
                TextButton(
                  onPressed: onEntrarTap,
                  child: const Text("Login", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
              ],
              if (onCadastroTap != null) ...[
                TextButton(
                  onPressed: onCadastroTap,
                  child: const Text("Cadastrar", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
              ],
              if (onComecarTap != null) ...[
                InkWell(
                  onTap: onComecarTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [Color(0xff22d3ee), Color(0xff34d399)],
                      ),
                    ),
                    child: const Text(
                      "Começar",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String text, bool active) {
    return GestureDetector(
      onTap: () {
        if (onTabTap != null) {
          onTabTap!(text);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          text,
          style: TextStyle(
            color: active ? const Color(0xff00f2ff) : Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
