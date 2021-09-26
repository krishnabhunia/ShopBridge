using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using ShopBridge.Filters;

namespace ShopBridge
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
            //filters.Add(new CustomExceptionFilter());

            //GlobalConfiguration.Configuration.Filters.Add(new CustomExceptionFilter());
        }
    }
}
