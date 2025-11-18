import '../datasources/api_client.dart';
import '../models/chat_message_model.dart';
import '../models/base_response_model.dart';

class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository(this._apiClient);

  /// Lấy lịch sử chat
  Future<List<ChatMessageModel>> getChatHistory() async {
    try {
      final BaseResponse<List<ChatMessageModel>> response =
          await _apiClient.getChatHistory();
      return response.data ?? [];
    } catch (_) {
      rethrow;
    }
  }

  /// Gửi tin nhắn
  Future<ChatMessageModel?> sendMessage(
    String message, {
    bool isMedicationQuestion = false,
  }) async {
    try {
      final BaseResponse<ChatMessageModel> response =
          await _apiClient.sendChatMessage(
        message,
        isMedicationQuestion: isMedicationQuestion,
      );
      final chatMessage = response.data;

      return chatMessage;
    } catch (_) {
      final mockResponse = ChatMessageModel(
        reply: 'Xin lỗi, tôi không thể trả lời ngay bây giờ. Vui lòng thử lại!',
      );

      return mockResponse;
    }
  }
}
