# TODO: Install JDK into the Project

- [x] Create jdk directory in project root
- [x] Download OpenJDK 17 zip from Adoptium
- [x] Extract JDK zip to jdk/ directory
- [x] Update android/gradle.properties to set org.gradle.java.home=../../jdk
- [x] Verify JDK setup with flutter doctor

## Community Page Discord-like Redesign

- [x] 1. Add state variables to _CommunityPageState: SelectedChannel? _selectedChannel; List<Message> _messages = []; List<MuralPost> _posts = []; TextEditingController _messageController = TextEditingController(); TextEditingController _titleController = TextEditingController(); TextEditingController _descriptionController = TextEditingController(); ScrollController _scrollController = ScrollController(); bool _contentLoading = false; bool _isSending = false; bool _isCreating = false; String? _contentError;

- [x] 2. Implement _selectChannel(Channel channel) method: Set _selectedChannel, reset lists/flags, load content based on channel.type ('chat' or 'mural').

- [x] 3. Implement chat methods: _loadMessages(String channelId), _sendMessage(), _scrollToBottom(), _buildMessageItem(Message message).

- [x] 4. Implement mural methods: _loadPosts(String channelId), _createPost(), _showCreatePostModal(), _buildPostItem(MuralPost post), _buildReplyItem(MuralPost reply).

- [x] 5. Implement unified _formatTimestamp(DateTime timestamp).

- [x] 6. Update initState(): Only load channels (_loadChannels()).

- [x] 7. Update dispose(): Dispose controllers and _scrollController.

- [x] 8. Update build(): If _isLoading (channels), show loader. Else, Scaffold with AppBar, body: Row( left: sidebar Container (width 280, bg AppColors.sidebar, ListView channels with onTap _selectChannel), right: Expanded main content: If no _selectedChannel, center text; else if chat: Column(private indicator, Expanded ListView messages with _buildMessageItem, bottom input Row); if mural: Column(private indicator, Expanded ListView posts with _buildPostItem, FAB for _showCreatePostModal). Handle _contentLoading, _contentError, empty states.

- [x] 9. Add necessary imports: from community_models.dart (Message, MuralPost), and ensure all are covered.

- [x] 10. Test: Run flutter run, select channels, verify chat/mural inline, sending/posting works, layout responsive, colors preserved.
