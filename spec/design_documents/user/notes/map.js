/*jshint -W025:false */
function (doc, meta) {
  if (doc.doc_type === "note") {
    emit(doc.user_id, null);
  }
}
