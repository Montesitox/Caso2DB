// insert_media.js
db.media_assets.insertOne({
    type: "image",
    url: "https://cdn.soltura.com/media/adquisicion-banner.jpg",
    tags: ["adquisición", "home", "anuncio"],
    alt: "Ahora somos parte de Soltura",
    uploaded_by: "webmaster@soltura.com",
    uploaded_at: new Date()
  })