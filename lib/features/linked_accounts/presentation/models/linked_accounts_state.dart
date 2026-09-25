class LinkedAccountsState {
  const LinkedAccountsState({
    this.isLoading = true,
    this.isBusy = false,
    this.googleLinked = false,
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoading;
  final bool isBusy;
  final bool googleLinked;
  final String? errorMessage;
  final String? infoMessage;

  LinkedAccountsState copyWith({
    bool? isLoading,
    bool? isBusy,
    bool? googleLinked,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return LinkedAccountsState(
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      googleLinked: googleLinked ?? this.googleLinked,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}
