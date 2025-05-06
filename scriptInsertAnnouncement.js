// insert_announcement.js
db.content_pages.insertOne({
    slug: "anuncio-adquisicion",
    title: "Ahora somos Soltura",
    sections: [
      {
        type: "text",
        content: "Nos complace anunciar que a partir del 1 de junio de 2025, la plataforma Payment Assistant ahora forma parte de Soltura. Seguimos comprometidos con ofrecerte más beneficios en un solo lugar."
      },
      {
        type: "banner",
        title: "¡Payment Assistant ahora es Soltura!",
        image_url: "https://cdn.soltura.com/media/adquisicion-banner.jpg",
        start_date: ISODate("2025-04-01T00:00:00Z"),
        end_date: ISODate("2025-07-01T00:00:00Z"),
        cta_text: "Consulta la guía de pasos para el cambio",
        cta_link: "https://www.soltura.com/guia-migracion-usuarios",
      }
    ],
    published: true,
    updated_at: new Date()
  })
  