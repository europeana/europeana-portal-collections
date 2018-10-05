# frozen_string_literal: true

module ExhibitionsHelper
  def exhibition_content(exhibition)
    return nil if exhibition.nil?

    {
      url: exhibition.url,
      state_1_title: exhibition.title,
      state_2_body: exhibition.description,
      state_3_logo: {
        thumbnail: {
          url: exhibition.credit_image
        }
      },
      state_1_label: false,
      state_1_image: {
        thumbnail: {
          url: exhibition.card_image
        }
      },
      state_2_image: {
        thumbnail: {
          url: exhibition.card_image
        }
      },
      state_3_image: {
        thumbnail:{
          url: exhibition.card_image
        }
      },
      excerpt: false,
      icon: "multi-page",
      title: exhibition.title,
      relation: "???(Contains this item?)",
      tags:{
        items: [
          {
            url: "http://europeana.eu/portal/exhibitions",
            text: "exhibition"
          }
        ]
      }
    }
  end
end
