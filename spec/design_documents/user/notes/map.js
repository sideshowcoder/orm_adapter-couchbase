/*jshint -W025:false */
function (doc, meta) {
  if (doc.type === "note") {
    emit(doc.user_id, null);
  }
}
