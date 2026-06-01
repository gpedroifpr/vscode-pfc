import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const DevStackApp());
}

class DevStackApp extends StatelessWidget {
  const DevStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B1215), // Fundo bem escuro
      ),
      home: const FeedScreen(),
    );
  }
}

// Classe para representar uma mensagem
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedIndex = 0;
  int _selectedTagIndex = 3; // JavaScript começa selecionado
  late List<ChatMessage> _chatMessages = [];
  bool _isLoadingAI = false;
  String _selectedAI = 'gemini'; // 'gemini' ou 'openai'

  // API Keys
  final String geminiApiKey = 'AIzaSyD_cZTIO0HIu7aV8amRcDUMfNq9InyLWDo';
  final String openaiApiKey = 'sk-proj-U2w5E8K1q9L2mN3oP4qR5sT6uV7wX8yZ'; // Coloque sua chave aqui

  final Color primaryCyan = const Color(0xFF4EE2EC); // Ciano neon
  final Color cardColor = const Color(0xFF162126); // Cinza azulado escuro
  final List<String> tags = ['Python', 'React', 'AI', 'JavaScript'];

  // Profile Controllers
  late TextEditingController _profileNameController;
  late TextEditingController _profileEmailController;
  late TextEditingController _profilePhoneController;
  late TextEditingController _profileCepController;
  late TextEditingController _profileRuaController;
  late TextEditingController _profileBairroController;
  late TextEditingController _profileCidadeController;
  late TextEditingController _profileEstadoController;
  late TextEditingController _profileNumeroController;
  late TextEditingController _profileComplementoController;
  bool _cepLoading = false;
  String? _cepError;
  bool _profileEditing = false;

  @override
  void initState() {
    super.initState();
    _profileNameController = TextEditingController();
    _profileEmailController = TextEditingController();
    _profilePhoneController = TextEditingController();
    _profileCepController = TextEditingController();
    _profileRuaController = TextEditingController();
    _profileBairroController = TextEditingController();
    _profileCidadeController = TextEditingController();
    _profileEstadoController = TextEditingController();
    _profileNumeroController = TextEditingController();
    _profileComplementoController = TextEditingController();
  }

  @override
  void dispose() {
    _profileNameController.dispose();
    _profileEmailController.dispose();
    _profilePhoneController.dispose();
    _profileCepController.dispose();
    _profileRuaController.dispose();
    _profileBairroController.dispose();
    _profileCidadeController.dispose();
    _profileEstadoController.dispose();
    _profileNumeroController.dispose();
    _profileComplementoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                // Conteúdo que muda conforme a aba selecionada - envolvido em Expanded
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
            _buildFloatingAskButton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // NOVO: Método que controla qual conteúdo mostrar
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: // Home (Feed)
        return _buildFeedContent();
      case 1: // Search
        return _buildSearchContent();
      case 2: // Notifications
        return _buildNotificationsContent();
      case 3: // Communities
        return _buildCommunitiesContent();
      case 4: // Profile
        return _buildProfileContent();
      case 5: // AI Conversation
        return _buildAIConversationContent();
      default:
        return _buildFeedContent();
    }
  }

  // NOVO: Conteúdo da aba HOME
  Widget _buildFeedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'My Feed',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Top Tags', style: TextStyle(color: Colors.grey)),
        ),
        _buildTagsRow(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildPostCard(),
              _buildSimplePostCard("AI integration for prediction modeling in Python"),
              _buildSimplePostCard("Deploying Docker containers to AWS Lambda"),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  // NOVO: Conteúdo da aba SEARCH
  Widget _buildSearchContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 60, color: primaryCyan),
          const SizedBox(height: 16),
          const Text(
            'Buscar Posts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Procure por tags, tópicos ou usuários',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // NOVO: Conteúdo da aba NOTIFICATIONS
  Widget _buildNotificationsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 60, color: primaryCyan),
          const SizedBox(height: 16),
          const Text(
            'Notificações',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Você não tem notificações',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // NOVO: Conteúdo da aba COMMUNITIES
  Widget _buildCommunitiesContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 60, color: primaryCyan),
          const SizedBox(height: 16),
          const Text(
            'Comunidades',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore comunidades interessantes',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // NOVO: Conteúdo da aba PROFILE
  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do Perfil
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryCyan.withValues(alpha: 0.3),
                  child: Icon(Icons.person, size: 50, color: primaryCyan),
                ),
                const SizedBox(height: 16),
                Text(
                  'Seu Perfil',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gerencie suas informações pessoais',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Botão Edit/Save
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  setState(() {
                    _profileEditing = !_profileEditing;
                  });
                },
                icon: Icon(_profileEditing ? Icons.check : Icons.edit),
                label: Text(_profileEditing ? 'Salvar' : 'Editar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Seção Dados Pessoais
          _buildProfileSection('Dados Pessoais', [
            _buildProfileTextField(
              'Nome Completo',
              _profileNameController,
              Icons.person,
              enabled: _profileEditing,
            ),
            _buildProfileTextField(
              'Email',
              _profileEmailController,
              Icons.email,
              enabled: _profileEditing,
            ),
            _buildProfileTextField(
              'Telefone',
              _profilePhoneController,
              Icons.phone,
              enabled: _profileEditing,
            ),
          ]),
          const SizedBox(height: 24),
          // Seção CEP (Obrigatória)
          _buildProfileSection('Endereço', [
            // Campo CEP com botão de consulta
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '📍 CEP *',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _profileCepController,
                        enabled: _profileEditing,
                        maxLength: 8,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '00000000',
                          hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: const Color(0xFF0F171A),
                          prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryCyan.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryCyan),
                          ),
                          counterText: '',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _cepError = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_profileEditing)
                      GestureDetector(
                        onTap: _profileCepController.text.length == 8
                            ? _consultarCEP
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _profileCepController.text.length == 8
                                ? primaryCyan
                                : Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _cepLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _profileCepController.text.length == 8
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.search,
                                  color: _profileCepController.text.length == 8
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                        ),
                      ),
                  ],
                ),
                if (_cepError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _cepError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '* Campo obrigatório - Consulte seu CEP para autopreenchimento de endereço',
                  style: TextStyle(
                    color: Colors.orange.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            _buildProfileTextField(
              'Rua',
              _profileRuaController,
              Icons.streetview,
              enabled: _profileEditing,
            ),
            _buildProfileTextField(
              'Número',
              _profileNumeroController,
              Icons.home,
              enabled: _profileEditing,
            ),
            _buildProfileTextField(
              'Complemento',
              _profileComplementoController,
              Icons.info_outline,
              enabled: _profileEditing,
            ),
            _buildProfileTextField(
              'Bairro',
              _profileBairroController,
              Icons.location_city,
              enabled: _profileEditing,
            ),
            _buildProfileTextField(
              'Cidade',
              _profileCidadeController,
              Icons.business,
              enabled: _profileEditing,
            ),
            _buildProfileTextField(
              'Estado',
              _profileEstadoController,
              Icons.map,
              enabled: _profileEditing,
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // NOVO: Conteúdo da aba AI CONVERSATION
  Widget _buildAIConversationContent() {
    return Column(
      children: [
        Expanded(
          child: _chatMessages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology, size: 60, color: primaryCyan),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhuma conversa iniciada',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Clique no botão "Ask AI" para começar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = _chatMessages[index];
                    return Align(
                      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: message.isUser ? primaryCyan : cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: !message.isUser ? Border.all(color: primaryCyan.withValues(alpha: 0.3)) : null,
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.isUser ? Colors.black : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (_isLoadingAI)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryCyan),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('IA está pensando...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
      ],
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.search, color: Colors.grey),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology, color: primaryCyan),
                const SizedBox(width: 5),
                Text(
                  'DevStack',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(' AI', style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _showAISettingsModal,
                child: Icon(
                  Icons.settings,
                  color: _selectedAI == 'gemini' ? Colors.purple : primaryCyan,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              const Stack(
                children: [
                  Icon(Icons.notifications_none, color: Colors.grey),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                  )
                ],
              ),
              const SizedBox(width: 15),
              CircleAvatar(
                radius: 18,
                backgroundColor: primaryCyan.withValues(alpha: 0.3),
                child: Icon(Icons.person, color: primaryCyan, size: 20),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTagsRow() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedTagIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTagIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? primaryCyan : Colors.grey.withValues(alpha: 0.3)),
                boxShadow: isSelected ? [BoxShadow(color: primaryCyan.withValues(alpha: 0.3), blurRadius: 8)] : [],
              ),
              child: Text(
                tags[index],
                style: TextStyle(color: isSelected ? primaryCyan : Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: primaryCyan.withValues(alpha: 0.3),
                child: Icon(Icons.person, size: 12, color: primaryCyan),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('@TechEnthusiast', style: TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
              ),
              const Text('3h ago', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Optimizing dynamic content loading in React with Hooks?',
            style: TextStyle(color: primaryCyan, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Learn about optimizing dynamic content loading from the miners in React hooks.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _buildCodeSnippet(),
          const SizedBox(height: 12),
          _buildCardFooter(),
        ],
      ),
    );
  }

  Widget _buildSimplePostCard(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              const Icon(Icons.more_vert, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 10),
          _buildCodeSnippet(minimized: true),
        ],
      ),
    );
  }

  Widget _buildCodeSnippet({bool minimized = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F171A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'useEffect(() => {',
            style: GoogleFonts.firaCode(color: Colors.greenAccent, fontSize: 12),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              'const fetchData = async () => {',
              style: GoogleFonts.firaCode(color: primaryCyan, fontSize: 12),
            ),
          ),
          if (!minimized) ...[
            const Padding(padding: EdgeInsets.only(left: 32), child: Text('...', style: TextStyle(color: Colors.white))),
            Text('}, []);', style: GoogleFonts.firaCode(color: Colors.greenAccent, fontSize: 12)),
          ]
        ],
      ),
    );
  }

  Widget _buildCardFooter() {
    return Row(
      children: [
        Icon(Icons.arrow_upward, size: 16, color: primaryCyan),
        const SizedBox(width: 4),
        const Text('1,489', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 12),
        const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        const Text('42', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 12),
        const Icon(Icons.share_outlined, size: 16, color: Colors.grey),
        const Spacer(),
        _miniTag("React"),
        _miniTag("Hooks"),
      ],
    );
  }

  Widget _miniTag(String label) {
    return Container(
      margin: const EdgeInsets.only(left: 5),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: primaryCyan.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: primaryCyan, fontSize: 9)),
    );
  }

  Widget _buildFloatingAskButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: _showAskAIDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: primaryCyan,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: primaryCyan.withValues(alpha: 0.6),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.help_outline, color: Colors.black),
              SizedBox(width: 8),
              Text('Ask AI', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAISettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: primaryCyan, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Escolha sua IA',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildAIOption('gemini', 'Google Gemini', 'Rápido e poderoso', Icons.auto_awesome),
            const SizedBox(height: 12),
            _buildAIOption('openai', 'OpenAI GPT', 'Preciso e versátil', Icons.lightbulb),
            const SizedBox(height: 24),
            Text(
              'IA Selecionada: ${_selectedAI == 'gemini' ? 'Google Gemini 🟣' : 'OpenAI GPT 💚'}',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIOption(String value, String name, String description, IconData icon) {
    final isSelected = _selectedAI == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAI = value;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('IA alterada para: $name ✨'),
            backgroundColor: isSelected ? Colors.purple : primaryCyan,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F171A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? (value == 'gemini' ? Colors.purple : primaryCyan) : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: value == 'gemini' ? Colors.purple : primaryCyan, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(description, style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: value == 'gemini' ? Colors.purple : primaryCyan, size: 24),
          ],
        ),
      ),
    );
  }

  void _showAskAIDialog() {
    final TextEditingController questionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Row(
          children: [
            Icon(Icons.psychology, color: primaryCyan),
            const SizedBox(width: 8),
            const Text('Ask AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Faça uma pergunta sobre código ou desenvolvimento:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: questionController,
                maxLines: 5,
                minLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ex: Como otimizar um useEffect em React?',
                  hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: const Color(0xFF0F171A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryCyan.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryCyan),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryCyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (questionController.text.isNotEmpty) {
                Navigator.pop(context);
                _sendQuestionToAI(questionController.text);
                questionController.clear();
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendQuestionToAI(String question) async {
    // Adicionar pergunta do usuário à conversa
    setState(() {
      _chatMessages.add(ChatMessage(
        text: question,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoadingAI = true;
      _selectedIndex = 5; // Ir para aba de conversa
    });

    try {
      // Fazer requisição HTTP direta à API do Gemini
      final apiKey = 'AIzaSyD_cZTIO0HIu7aV8amRcDUMfNq9InyLWDo';
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': question}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final aiResponse = jsonResponse['candidates'][0]['content']['parts'][0]['text'] ?? 'Desculpe, não consegui gerar uma resposta.';

        setState(() {
          _chatMessages.add(ChatMessage(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoadingAI = false;
        });
      } else if (response.statusCode == 429) {
        setState(() {
          _chatMessages.add(ChatMessage(
            text: '⏳ Limite de requisições atingido. Por favor, aguarde alguns minutos antes de fazer outra pergunta.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoadingAI = false;
        });
      } else {
        setState(() {
          _chatMessages.add(ChatMessage(
            text: '❌ Erro ao conectar com a IA. Código de erro: ${response.statusCode}',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoadingAI = false;
        });
      }
    } catch (e) {
      setState(() {
        _chatMessages.add(ChatMessage(
          text: '❌ Erro ao conectar com a IA: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoadingAI = false;
      });
    }
  }

  // Método para consultar CEP
  Future<void> _consultarCEP() async {
    final cep = _profileCepController.text.replaceAll(RegExp(r'\D'), '');

    if (cep.isEmpty || cep.length != 8) {
      setState(() {
        _cepError = 'CEP inválido. Use apenas 8 dígitos.';
      });
      return;
    }

    setState(() {
      _cepLoading = true;
      _cepError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['erro'] == true) {
          setState(() {
            _cepError = '❌ CEP não encontrado';
            _cepLoading = false;
          });
        } else {
          setState(() {
            _profileRuaController.text = data['logradouro'] ?? '';
            _profileBairroController.text = data['bairro'] ?? '';
            _profileCidadeController.text = data['localidade'] ?? '';
            _profileEstadoController.text = data['uf'] ?? '';
            _cepLoading = false;
            _cepError = null;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('✅ CEP consultado com sucesso!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          });
        }
      } else {
        setState(() {
          _cepError = '❌ Erro ao consultar CEP';
          _cepLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _cepError = '❌ Erro na conexão: ${e.toString()}';
        _cepLoading = false;
      });
    }
  }

  // Widget para seção de perfil
  Widget _buildProfileSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: primaryCyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Widget para campo de texto do perfil
  Widget _buildProfileTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
            filled: true,
            fillColor: const Color(0xFF0F171A),
            prefixIcon: Icon(icon, color: primaryCyan),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryCyan.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryCyan),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final navItems = [
      {'icon': Icons.home_filled, 'label': 'Home'},
      {'icon': Icons.search, 'label': 'Search'},
      {'icon': Icons.notifications_none, 'label': 'Notif'},
      {'icon': Icons.people_outline, 'label': 'Communities'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
      {'icon': Icons.psychology, 'label': 'AI Chat'},
    ];

    return Container(
      color: const Color(0xFF0B1215),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          navItems.length,
          (index) => GestureDetector(
            onTap: () {
              print('Clicado em aba: $index');
              setState(() {
                _selectedIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Icon(
                navItems[index]['icon'] as IconData,
                color: _selectedIndex == index ? primaryCyan : Colors.grey,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}