// Match OpenCode's current-context accounting, including compaction and undo.
export function highContextPercent(messages, models, boundary) {
  const boundaryIndex = boundary
    ? messages.findIndex((message) => message.id === boundary)
    : -1;
  if (boundary && boundaryIndex === -1) return;
  const end = boundaryIndex === -1 ? messages.length : boundaryIndex;
  const compactionIndex = messages.findLastIndex(
    (message, index) =>
      message.type === "compaction" &&
      message.status === "completed" &&
      index < end,
  );
  const last = messages.findLast(
    (message, index) =>
      message.type === "assistant" &&
      message.tokens !== undefined &&
      index > compactionIndex &&
      index < end,
  );
  if (!last) return;
  const model = models?.find(
    (model) =>
      model.providerID === last.model.providerID && model.id === last.model.id,
  );
  if (!model?.limit.context) return;
  const tokens =
    last.tokens.input +
    last.tokens.output +
    last.tokens.reasoning +
    last.tokens.cache.read +
    last.tokens.cache.write;
  const percent = (tokens / model.limit.context) * 100;
  if (percent >= 80) return Math.round(percent);
}
