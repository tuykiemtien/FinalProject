using FinalProjectAPI.Business;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace FinalProjectAPI.Controllers
{
    public class UserController : ApiController
    {
		private UserBusiness userBusiness;
		public UserController()
		{
			userBusiness = new UserBusiness();
		}
		[HttpGet]
		public IHttpActionResult GetUserByEmail(string email)
		{
			try
			{
				return Ok(userBusiness.GetUserByEmail(email));				
			}
			catch(Exception e)
			{
				return InternalServerError();
			}
		}
    }
}
