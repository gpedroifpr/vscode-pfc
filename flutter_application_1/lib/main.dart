import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Carregar variáveis de ambiente do arquivo .env
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Aviso: Arquivo .env não encontrado. Usando variáveis padrão.');
  }
  runApp(const DevStackApp());
}

class DevStackApp extends StatelessWidget {
  const DevStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B1215),
      ),
      home: const FeedScreen(),
    );
  }
}

// ============= MODELOS DE DADOS =============

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

class Post {
  final String id;
  final String username;
  final String userHandle;
  final String title;
  final String description;
  final String code;
  final List<String> tags;
  final int likes;
  final int comments;
  final String timeAgo;
  bool isLiked;
  bool isFavorited;

  Post({
    required this.id,
    required this.username,
    required this.userHandle,
    required this.title,
    required this.description,
    required this.code,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    this.isLiked = false,
    this.isFavorited = false,
  });
}

class Notification {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final String type;
  bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
  });
}

class Community {
  final String id;
  final String name;
  final String description;
  final int members;
  final String icon;
  bool isFollowed;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.icon,
    this.isFollowed = false,
  });
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _selectedTagIndex = 3;
  bool _isShowingSearch = false;
  bool _isShowingNotifications = false;
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;
  
  late List<ChatMessage> _chatMessages = [];
  late List<Post> _allPosts = [];
  late List<Post> _filteredPosts = [];
  late List<Notification> _notifications = [];
  late List<Community> _communities = [];
  late List<String> _searchHistory = [];

  bool _isLoadingAI = false;
  String _selectedAI = 'gemini';
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  final Color primaryCyan = const Color(0xFF4EE2EC);
  final Color cardColor = const Color(0xFF162126);
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
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );
    _transitionController.forward();
    
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

    _initializeData();
  }

  Future<void> _initializeData() async {
    _allPosts = _generateSamplePosts();
    _filteredPosts = _allPosts;
    _notifications = _generateSampleNotifications();
    _communities = _generateSampleCommunities();
    _searchHistory = await _loadSearchHistory();
    setState(() {});
  }

  List<Post> _generateSamplePosts() {
    return [
      Post(
        id: '1',
        username: 'Alex Chen',
        userHandle: '@techguru',
        title: 'Optimizing React Hooks for Performance',
        description: 'Learn the best practices for using useCallback and useMemo in your React applications.',
        code: 'useCallback(() => {\n  const fetchData = async () => {\n    // fetch logic\n  };\n}, [deps]);',
        tags: ['React', 'JavaScript', 'Performance'],
        likes: 1489,
        comments: 42,
        timeAgo: '3h ago',
      ),
      Post(
        id: '2',
        username: 'Sarah Kumar',
        userHandle: '@pythonista',
        title: 'Advanced Python Async/Await Patterns',
        description: 'Master concurrent programming with asyncio for high-performance applications.',
        code: 'async def fetch_data():\n  tasks = [fetch_url(url) for url in urls]\n  results = await asyncio.gather(*tasks)',
        tags: ['Python', 'Async', 'Backend'],
        likes: 856,
        comments: 23,
        timeAgo: '5h ago',
      ),
      Post(
        id: '3',
        username: 'Mike Wilson',
        userHandle: '@fullstackdev',
        title: 'Building Real-time Chat with WebSockets',
        description: 'Complete guide to implementing WebSockets in your web applications.',
        code: 'const socket = io();\nsocket.on("message", (data) => {\n  console.log(data);\n});',
        tags: ['WebSocket', 'JavaScript', 'Real-time'],
        likes: 623,
        comments: 15,
        timeAgo: '7h ago',
      ),
      Post(
        id: '4',
        username: 'Emma Rodriguez',
        userHandle: '@airesearcher',
        title: 'Implementing Transformer Models from Scratch',
        description: 'Deep dive into attention mechanisms and neural network architecture.',
        code: 'class Transformer(nn.Module):\n  def forward(self, x):\n    return self.attention(x)',
        tags: ['AI', 'Python', 'ML'],
        likes: 2104,
        comments: 67,
        timeAgo: '12h ago',
      ),
      Post(
        id: '5',
        username: 'James Park',
        userHandle: '@devops_ninja',
        title: 'Docker Container Orchestration Best Practices',
        description: 'Kubernetes tips and tricks for production deployments.',
        code: 'apiVersion: v1\nkind: Pod\nmetadata:\n  name: nginx',
        tags: ['Docker', 'DevOps', 'Kubernetes'],
        likes: 456,
        comments: 12,
        timeAgo: '1d ago',
      ),
    ];
  }

  List<Notification> _generateSampleNotifications() {
    return [
      Notification(
        id: '1',
        title: 'New Comment',
        message: '@sarah_dev commented on your post about React Hooks',
        timeAgo: '2 min ago',
        type: 'comment',
      ),
      Notification(
        id: '2',
        title: 'New Follower',
        message: '@code_master started following you',
        timeAgo: '15 min ago',
        type: 'follow',
      ),
      Notification(
        id: '3',
        title: 'Community Invite',
        message: 'You were invited to join "AI Enthusiasts" community',
        timeAgo: '1h ago',
        type: 'community',
      ),
      Notification(
        id: '4',
        title: 'Post Trending',
        message: 'Your post "Building Real-time Apps" is trending!',
        timeAgo: '3h ago',
        type: 'trending',
      ),
    ];
  }

  List<Community> _generateSampleCommunities() {
    return [
      Community(
        id: '1',
        name: 'React Developers',
        description: 'Connect with React enthusiasts and share best practices',
        members: 15420,
        icon: '⚛️',
      ),
      Community(
        id: '2',
        name: 'Python Masters',
        description: 'Advanced Python programming and best practices',
        members: 22890,
        icon: '🐍',
      ),
      Community(
        id: '3',
        name: 'AI & Machine Learning',
        description: 'Explore cutting-edge AI and ML technologies',
        members: 18760,
        icon: '🤖',
      ),
      Community(
        id: '4',
        name: 'DevOps Engineers',
        description: 'Share DevOps experiences and tools',
        members: 12340,
        icon: '⚙️',
      ),
      Community(
        id: '5',
        name: 'Web Design',
        description: 'Modern web design and UX/UI tips',
        members: 9876,
        icon: '🎨',
      ),
    ];
  }

  Future<List<String>> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('search_history') ?? [];
  }

  Future<void> _addToSearchHistory(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.removeWhere((item) => item == query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 10) _searchHistory = _searchHistory.take(10).toList();
    await prefs.setStringList('search_history', _searchHistory);
  }

  void _searchPosts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPosts = _allPosts;
      } else {
        _filteredPosts = _allPosts
            .where((post) =>
                post.title.toLowerCase().contains(query.toLowerCase()) ||
                post.description.toLowerCase().contains(query.toLowerCase()) ||
                post.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _transitionController.dispose();
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
    _searchController.dispose();
    super.dispose();
  }

  void _changeScreen() {
    _transitionController.reset();
    _transitionController.forward();
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
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildContent(),
                  ),
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

  Widget _buildContent() {
    if (_isShowingSearch) {
      return _buildSearchContent();
    }
    if (_isShowingNotifications) {
      return _buildNotificationsContent();
    }
    
    switch (_selectedIndex) {
      case 0:
        return _buildFeedContent();
      case 1:
        return _buildCommunitiesContent();
      case 2:
        return _buildProfileContent();
      case 3:
        return _buildAIConversationContent();
      default:
        return _buildFeedContent();
    }
  }

  // ============= FEED CONTENT =============

  Widget _buildFeedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'My Feed',
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Top Tags', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        _buildTagsRow(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _allPosts.length + 1,
            itemBuilder: (context, index) {
              if (index == _allPosts.length) {
                return const SizedBox(height: 80);
              }
              return _buildPostCardWidget(_allPosts[index]);
            },
          ),
        ),
      ],
    );
  }

  // ============= SEARCH CONTENT =============

  Widget _buildSearchContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _searchPosts,
            onSubmitted: (query) {
              _addToSearchHistory(query);
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Procurar posts, tags ou usuários...',
              hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.search, color: primaryCyan),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _searchPosts('');
                      },
                      child: Icon(Icons.close, color: primaryCyan),
                    )
                  : null,
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryCyan.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryCyan),
              ),
            ),
          ),
        ),
        Expanded(
          child: _searchQuery.isEmpty
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_searchHistory.isNotEmpty) ...[
                          Text('Histórico de Buscas',
                              style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _searchHistory
                                .map((query) => GestureDetector(
                                      onTap: () {
                                        _searchController.text = query;
                                        _searchPosts(query);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: primaryCyan.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(query, style: TextStyle(color: primaryCyan, fontSize: 12)),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredPosts.length,
                  itemBuilder: (context, index) => _buildPostCardWidget(_filteredPosts[index]),
                ),
        ),
      ],
    );
  }

  // ============= NOTIFICATIONS CONTENT =============

  Widget _buildNotificationsContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notif = _notifications[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _getNotificationIcon(notif.type),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(notif.message, style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(notif.timeAgo, style: TextStyle(color: Colors.grey.withValues(alpha: 0.7), fontSize: 10)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    notif.isRead = !notif.isRead;
                  });
                },
                child: Icon(
                  notif.isRead ? Icons.check_circle : Icons.circle_outlined,
                  color: primaryCyan,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Icon _getNotificationIcon(String type) {
    switch (type) {
      case 'comment':
        return Icon(Icons.comment, color: primaryCyan);
      case 'follow':
        return Icon(Icons.person_add, color: primaryCyan);
      case 'community':
        return Icon(Icons.people, color: primaryCyan);
      case 'trending':
        return Icon(Icons.trending_up, color: primaryCyan);
      default:
        return Icon(Icons.notifications, color: primaryCyan);
    }
  }

  // ============= COMMUNITIES CONTENT =============

  Widget _buildCommunitiesContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _communities.length,
      itemBuilder: (context, index) {
        final community = _communities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Text(community.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(community.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(community.description, style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('${community.members} membros', style: TextStyle(color: Colors.grey.withValues(alpha: 0.7), fontSize: 10)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: community.isFollowed ? Colors.grey.withValues(alpha: 0.3) : primaryCyan,
                  foregroundColor: community.isFollowed ? primaryCyan : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: () {
                  setState(() {
                    community.isFollowed = !community.isFollowed;
                  });
                },
                child: Text(community.isFollowed ? 'Seguindo' : 'Seguir', style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============= PROFILE CONTENT =============

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
          _buildProfileSection('Dados Pessoais', [
            _buildProfileTextField('Nome Completo', _profileNameController, Icons.person, enabled: _profileEditing),
            _buildProfileTextField('Email', _profileEmailController, Icons.email, enabled: _profileEditing),
            _buildProfileTextField('Telefone', _profilePhoneController, Icons.phone, enabled: _profileEditing),
          ]),
          const SizedBox(height: 24),
          _buildProfileSection('Endereço', [
            _buildCEPField(),
            _buildProfileTextField('Rua', _profileRuaController, Icons.streetview, enabled: _profileEditing),
            _buildProfileTextField('Número', _profileNumeroController, Icons.home, enabled: _profileEditing),
            _buildProfileTextField('Complemento', _profileComplementoController, Icons.info_outline, enabled: _profileEditing),
            _buildProfileTextField('Bairro', _profileBairroController, Icons.location_city, enabled: _profileEditing),
            _buildProfileTextField('Cidade', _profileCidadeController, Icons.business, enabled: _profileEditing),
            _buildProfileTextField('Estado', _profileEstadoController, Icons.map, enabled: _profileEditing),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCEPField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('📍 CEP *', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                onTap: _profileCepController.text.length == 8 ? _consultarCEP : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _profileCepController.text.length == 8 ? primaryCyan : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _cepLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _profileCepController.text.length == 8 ? Colors.black : Colors.grey,
                            ),
                          ),
                        )
                      : Icon(Icons.search, color: _profileCepController.text.length == 8 ? Colors.black : Colors.grey),
                ),
              ),
          ],
        ),
        if (_cepError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_cepError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        const SizedBox(height: 8),
        Text(
          '* Campo obrigatório - Consulte seu CEP para autopreenchimento de endereço',
          style: TextStyle(color: Colors.orange.withValues(alpha: 0.7), fontSize: 11),
        ),
      ],
    );
  }

  // ============= AI CONVERSATION CONTENT =============

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
                      const Text('Nenhuma conversa iniciada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Clique no botão "Ask AI" para começar', style: TextStyle(color: Colors.grey)),
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
                          style: TextStyle(color: message.isUser ? Colors.black : Colors.white, fontSize: 14),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _isShowingSearch ? primaryCyan.withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.search, color: _isShowingSearch ? primaryCyan : Colors.grey),
                  onPressed: () {
                    _changeScreen();
                    setState(() {
                      _isShowingSearch = !_isShowingSearch;
                      _isShowingNotifications = false;
                    });
                  },
                ),
              ),
              Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _isShowingNotifications ? primaryCyan.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.notifications_none, color: _isShowingNotifications ? primaryCyan : Colors.grey),
                      onPressed: () {
                        _changeScreen();
                        setState(() {
                          _isShowingNotifications = !_isShowingNotifications;
                          _isShowingSearch = false;
                        });
                      },
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                  )
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, color: primaryCyan),
              const SizedBox(width: 5),
              Text('DevStack', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(' AI', style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold)),
            ],
          ),
          GestureDetector(
            onTap: _showAISettingsModal,
            child: Icon(Icons.settings, color: primaryCyan, size: 24),
          ),
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
              setState(() => _selectedTagIndex = index);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? primaryCyan : Colors.grey.withValues(alpha: 0.3)),
                boxShadow: isSelected ? [BoxShadow(color: primaryCyan.withValues(alpha: 0.3), blurRadius: 8)] : [],
              ),
              child: Text(tags[index], style: TextStyle(color: isSelected ? primaryCyan : Colors.grey)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCardWidget(Post post) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.username, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(post.userHandle, style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Text(post.timeAgo, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.title, style: TextStyle(color: primaryCyan, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(post.description, style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F171A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                post.code,
                style: GoogleFonts.firaCode(color: Colors.greenAccent, fontSize: 11),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => post.isLiked = !post.isLiked);
                },
                child: Row(
                  children: [
                    Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, size: 16, color: post.isLiked ? Colors.red : primaryCyan),
                    const SizedBox(width: 4),
                    Text('${post.likes + (post.isLiked ? 1 : 0)}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${post.comments}', style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(width: 12),
              const Icon(Icons.share_outlined, size: 16, color: Colors.grey),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() => post.isFavorited = !post.isFavorited);
                },
                child: Icon(post.isFavorited ? Icons.bookmark : Icons.bookmark_border, size: 16, color: primaryCyan),
              ),
              ...post.tags.map((tag) => _miniTag(tag)),
            ],
          ),
        ],
      ),
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
      bottom: 80,
      right: 20,
      child: GestureDetector(
        onTap: _showAskAIDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: primaryCyan,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: primaryCyan.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 2)],
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
    setState(() {
      _chatMessages.add(ChatMessage(
        text: question,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoadingAI = true;
      _selectedIndex = 5;
    });

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];

      if (apiKey == null || apiKey.isEmpty || apiKey.contains('SUA_CHAVE')) {
        setState(() {
          _chatMessages.add(ChatMessage(
            text: '❌ Erro: Chave API do Gemini não configurada!\n\nPor favor:\n1. Vá para https://aistudio.google.com/app/apikeys\n2. Crie uma nova chave API\n3. Adicione ao arquivo .env: GEMINI_API_KEY=sua_chave_aqui',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoadingAI = false;
        });
        return;
      }

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
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => http.Response('Timeout', 504),
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
            text: '⏳ Limite de requisições atingido (429).\n\nIsso significa:\n• Você excedeu a quota diária (1000 req/dia no plano gratuito)\n• Aguarde até amanhã ou atualize para um plano pago\n• Acesse: https://console.cloud.google.com/billing',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoadingAI = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _chatMessages.add(ChatMessage(
            text: '❌ Erro 401: Chave API inválida ou expirada.\n\nSolução:\n1. Verifique a chave no arquivo .env\n2. Gere uma nova em: https://aistudio.google.com/app/apikeys',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoadingAI = false;
        });
      } else if (response.statusCode == 504) {
        setState(() {
          _chatMessages.add(ChatMessage(
            text: '⏱️ Timeout: A IA demorou muito para responder.\n\nTente novamente em alguns segundos.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoadingAI = false;
        });
      } else {
        setState(() {
          _chatMessages.add(ChatMessage(
            text: '❌ Erro ${response.statusCode}:\n${response.body.substring(0, 200)}',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoadingAI = false;
        });
      }
    } catch (e) {
      setState(() {
        _chatMessages.add(ChatMessage(
          text: '❌ Erro de conexão: ${e.toString()}\n\nVerifique sua conexão com a internet.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoadingAI = false;
      });
    }
  }

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
              _changeScreen();
              setState(() {
                _selectedIndex = index;
                _isShowingSearch = false;
                _isShowingNotifications = false;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              decoration: BoxDecoration(
                color: _selectedIndex == index ? primaryCyan.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: _selectedIndex == index ? 1.1 : 1.0,
                    child: Icon(
                      navItems[index]['icon'] as IconData,
                      color: _selectedIndex == index ? primaryCyan : Colors.grey,
                      size: 24,
                    ),
                  ),
                  Text(navItems[index]['label'] as String,
                      style: TextStyle(
                          color: _selectedIndex == index ? primaryCyan : Colors.grey,
                          fontSize: 9,
                          fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
