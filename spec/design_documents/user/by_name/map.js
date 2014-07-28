/*jshint -W025:false */
function (doc, meta) {
  if (doc.type === "user") {
    emit(doc.name, null);
  }
}
