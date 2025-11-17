import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/chat_message_model.dart';
import '../../data/repositories/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  ChatCubit(this._repository) : super(ChatInitial());

  /// Gửi tin nhắn và thêm vào list hiển thị
  Future<void> sendMessage(String message,
      {bool isMedicationQuestion = false}) async {
    if (message.trim().isEmpty) return;

    final currentMessages =
        state is ChatLoaded ? (state as ChatLoaded).messages : [];

    // Thêm tin nhắn người dùng ngay lập tức
    final userMessage = ChatMessageModel(reply: message, isUser: true);
    emit(ChatLoaded([...currentMessages, userMessage]));

    try {
      final response = await _repository.sendMessage(
        message,
        isMedicationQuestion: isMedicationQuestion,
      );

      if (response != null) {
        // Thêm phản hồi AI
        final aiMessage =
            ChatMessageModel(reply: response.reply, isUser: false);
        emit(ChatLoaded([...currentMessages, userMessage, aiMessage]));
      }
    } catch (e) {
      final errorMessage = ChatMessageModel(
        reply: 'Xin lỗi, không gửi được tin nhắn. Thử lại!',
        isUser: false,
      );
      emit(ChatLoaded([...currentMessages, userMessage, errorMessage]));
    }
  }
}
