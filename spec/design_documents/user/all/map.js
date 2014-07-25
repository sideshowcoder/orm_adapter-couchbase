/*jshint -W025:false */
function (doc, meta) {
  if (doc.type === "user") {
    emit(meta.id, null);
  }
}
