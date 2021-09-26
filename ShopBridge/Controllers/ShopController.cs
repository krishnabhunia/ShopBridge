using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;
using ShopBridge.Filters;
using ShopBridge.Models;

namespace ShopBridge.Controllers
{
    //[CustomExceptionFilter]
    public class ShopController : ApiController
    {
        private const string str_ServerName = ".";
        private const string str_DBName = "db_ShopBridge";
        private const string str_Username = "sa";
        private const string str_Password = "1234";
        string str = string.Empty;

        //private readonly string strConnectionString = $"Data Source = {str_ServerName};Initial Catalog = {str_DBName}; User ID = {str_Username};Password = {str_Password};";

        private readonly string strConnectionString = $"Data Source = {str_ServerName};Initial Catalog = {str_DBName}; Integrated Security = true";

        [HttpPut]
        public async Task<HttpResponseMessage> AddItem([FromBody] Product product)
        {
            if (ModelState.IsValid)
            {
                str = ProcessProduct("insert", product).ToString();
                return await Task.FromResult(Request.CreateResponse(HttpStatusCode.Created,str));
            }
            else
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, ModelState);
            }
        }

        [HttpPatch]
        public async Task<HttpResponseMessage> UpdateItem([FromBody] Product product)
        {
            if (ModelState.IsValid)
            {
                str = ProcessProduct("update", product);
                return await Task.FromResult(Request.CreateResponse(HttpStatusCode.Accepted, str));
            }
            else
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, ModelState);
            }
        }

        [HttpDelete]
        public async Task<HttpResponseMessage> DeleteItem([FromUri] int productID)
        {
            Product deleteProd = new Product();
            deleteProd.Product_ID = productID;
            if (ModelState.IsValid)
            {
                str = ProcessProduct("delete", deleteProd);
                return await Task.FromResult(Request.CreateResponse(HttpStatusCode.Accepted, str));
            }
            else
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, ModelState);
            }
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetProduct()
        {
            DataTable dt = new DataTable();
            if (ModelState.IsValid)
            {
                using (SqlConnection sqlCon = new SqlConnection(strConnectionString))
                {
                    using (SqlDataAdapter sqlDA = new SqlDataAdapter("list", sqlCon))
                    {
                        sqlDA.SelectCommand.CommandTimeout = 0;
                        sqlDA.SelectCommand.CommandType = CommandType.StoredProcedure;
                        sqlCon.Open();
                        sqlDA.Fill(dt);
                    }
                }
            }
            else
            {
                return await Task<HttpResponseMessage>.FromResult<HttpResponseMessage>(Request.CreateResponse(HttpStatusCode.InternalServerError));
            }
            return await Task<HttpResponseMessage>.FromResult<HttpResponseMessage>(Request.CreateResponse(HttpStatusCode.OK,dt));
        }


        private string ProcessProduct(string strProcessType, Product p)//, out StringBuilder strMessage)
        {
            string strMessage = string.Empty;
            using (SqlConnection sqlCon = new SqlConnection(strConnectionString))
            {
                using (SqlCommand sqlCmd = new SqlCommand("process", sqlCon))
                {
                    sqlCmd.CommandTimeout = 0;
                    sqlCmd.CommandType = CommandType.StoredProcedure;
                    switch (strProcessType)
                    {
                        case "insert":
                            sqlCmd.CommandText = "p_addItem";
                            sqlCmd.Parameters.AddWithValue("@name", p.ProductName);
                            sqlCmd.Parameters.AddWithValue("@desc", p.ProductDescription);
                            sqlCmd.Parameters.AddWithValue("@price", p.ProductPrice);
                            break;

                        case "update":
                            sqlCmd.CommandText = "p_updateItem";
                            sqlCmd.Parameters.AddWithValue("@product_id", p.Product_ID);
                            sqlCmd.Parameters.AddWithValue("@name", p.ProductName);
                            sqlCmd.Parameters.AddWithValue("@desc", p.ProductDescription);
                            sqlCmd.Parameters.AddWithValue("@price", p.ProductPrice);
                            break;

                        case "delete":
                            sqlCmd.CommandText = "p_deleteItem";
                            sqlCmd.Parameters.AddWithValue("@product_id", p.Product_ID);
                            break;

                    }

                    sqlCon.Open();
                    int int_Rows_Affected = sqlCmd.ExecuteNonQuery();
                    strMessage = $"Rows affected are {int_Rows_Affected}";
                }
            }

            return strMessage;
        }

    }
}
