using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;

namespace ShopBridge.Models
{
    public class Product
    {
        public decimal Product_ID { get; set; }
        [Required,MinLength(3), MaxLength(100)]
        public string ProductName { get; set; }

        public string ProductDescription { get; set; }
        [Required]
        public decimal ProductPrice { get; set; }

    }
}