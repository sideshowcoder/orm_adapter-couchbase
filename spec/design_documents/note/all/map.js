/*jshint -W025:false */
function (doc, meta) {
  if (doc.type === "note") {
    emit(meta.id, null);
  }
}
