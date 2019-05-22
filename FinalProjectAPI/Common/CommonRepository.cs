using FinalProjectAPI.Constant;
using FinalProjectAPI.Entites.CommonEntites;
using Microsoft.Practices.EnterpriseLibrary.Data;
using NLog;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using System.Web;

namespace FinalProjectAPI.Common
{
	public class CommonRepository<TEntityType>
	{
		protected readonly Logger Logger = LogManager.GetCurrentClassLogger();
		protected readonly Database Database;
		protected int TimeOutSeconds = 30;

		public CommonRepository()
		{
			var factory = new DatabaseProviderFactory();
			Database = factory.Create(CommonMessage.DatabaseContext);
		}

		#region Private Methods

		private static IEnumerable<PropertyInfo> GetAllProperties<T>()
		{
			return typeof(T).GetProperties().Where(info => info.GetMethod != null && info.GetMethod.IsPublic
					&& info.SetMethod != null && info.SetMethod.IsPublic
					&& !Attribute.IsDefined(info, typeof(NotMappedAttribute))).ToList();
		}

		private TStoredProcedureType MapRow<TStoredProcedureType>(IDataReader reader)
		{
			var entity = (TStoredProcedureType)Activator.CreateInstance(typeof(TStoredProcedureType));
			//Get all columns from reader 
			var columnNames = Enumerable.Range(0, reader.FieldCount).Select(reader.GetName).ToList();
			foreach (var propertyInfo in GetAllProperties<TStoredProcedureType>())
			{
				if (columnNames.Any(t => t.Equals(propertyInfo.Name, StringComparison.InvariantCultureIgnoreCase)))
				{
					if (reader[propertyInfo.Name] is DBNull) continue;

					var propertyType = propertyInfo.PropertyType;
					if (propertyType == typeof(bool) || propertyType == typeof(bool?))
					{
						propertyInfo.SetValue(entity, bool.Parse(reader[propertyInfo.Name].ToString()), null);
					}
					else if (propertyType == typeof(byte) || propertyType == typeof(byte?))
					{
						propertyInfo.SetValue(entity, byte.Parse(reader[propertyInfo.Name].ToString()), null);
					}
					else if (propertyType == typeof(DateTime) || propertyType == typeof(DateTime?))
					{
						propertyInfo.SetValue(entity, DateTime.Parse(reader[propertyInfo.Name].ToString()), null);
					}
					else if (propertyType == typeof(decimal) || propertyType == typeof(decimal?))
					{
						propertyInfo.SetValue(entity, decimal.Parse(reader[propertyInfo.Name].ToString()), null);
					}
					else if (propertyType == typeof(double) || propertyType == typeof(double?))
					{
						propertyInfo.SetValue(entity, double.Parse(reader[propertyInfo.Name].ToString()), null);
					}
					else if (propertyType == typeof(float) || propertyType == typeof(float?))
					{
						propertyInfo.SetValue(entity, float.Parse(reader[propertyInfo.Name].ToString()), null);
					}
					else if (propertyType == typeof(Guid) || propertyType == typeof(Guid?))
					{
						propertyInfo.SetValue(entity, Guid.Parse(reader[propertyInfo.Name].ToString()), null);
					}
					else if (propertyType == typeof(short) || propertyType == typeof(short?))
					{
						propertyInfo.SetValue(entity, short.Parse(reader[propertyInfo.Name].ToString()), null);
					}
					else if (propertyType == typeof(int) || propertyType == typeof(int?))
					{
						propertyInfo.SetValue(entity, int.Parse(reader[propertyInfo.Name].ToString()), null);
					}
					else if (propertyType == typeof(long) || propertyType == typeof(long?))
					{
						propertyInfo.SetValue(entity, long.Parse(reader[propertyInfo.Name].ToString()), null);
					}
					else if (propertyType == typeof(string))
					{
						propertyInfo.SetValue(entity, reader[propertyInfo.Name].ToString(), null);
					}
				}
			}
			return entity;
		}

		private void PrepareParameters(DbCommand sqlCmd, params StoredProcedureParameter[] parameters)
		{
			if (parameters == null) return;
			foreach (var para in parameters)
			{
				switch (para.Direction)
				{
					case ParameterDirection.Input:
						if (para.DbType == DbType.Object)
							sqlCmd.Parameters.Add(new SqlParameter($"@{para.Name}", SqlDbType.Structured) { Value = para.Value });
						else if (para.DbType == DbType.DateTime && (para.Value == null || (DateTime)para.Value == DateTime.MinValue))
							Database.AddInParameter(sqlCmd, para.Name, para.DbType, DBNull.Value);
						else
							Database.AddInParameter(sqlCmd, para.Name, para.DbType, para.Value);
						break;
					case ParameterDirection.Output:
						Database.AddOutParameter(sqlCmd, para.Name, para.DbType, para.Size);
						break;
				}
			}
		}

		#endregion

		public List<TEntityType> ListByStoredProcedure(string storedName, params StoredProcedureParameter[] parameters)
		{
			return ListByStoredProcedure<TEntityType>(storedName, parameters);
		}

		public List<TEntityType> GetByStoredProcedure(string storedName, params StoredProcedureParameter[] parameters)
		{
			return GetByStoredProcedure<TEntityType>(storedName, parameters);
		}

		public List<TStoredProcedureType> ListByStoredProcedure<TStoredProcedureType>(string storedName, params StoredProcedureParameter[] parameters)
		{
			try
			{
				var result = new List<TStoredProcedureType>();
				using (var sqlCmd = Database.GetStoredProcCommand(storedName))
				{
					sqlCmd.CommandTimeout = TimeOutSeconds;
					PrepareParameters(sqlCmd, parameters);
					using (var reader = Database.ExecuteReader(sqlCmd))
					{
						while (reader.Read())
						{
							result.Add(MapRow<TStoredProcedureType>(reader));
						}
						reader.Close();
						foreach (var parameter in parameters.Where(t => t.Direction == ParameterDirection.Output))
						{
							parameter.Value = Database.GetParameterValue(sqlCmd, $"@{parameter.Name}");
						}
					}
				}
				return new List<TStoredProcedureType>(result);
			}
			catch (Exception e)
			{
				Logger.Error($"ListByStoredProcedure<{typeof(TStoredProcedureType).Name}> exception: {e.Message}\n {e.StackTrace}");
				return new List<TStoredProcedureType>();
			}
		}

		public List<TStoredProcedureType> GetByStoredProcedure<TStoredProcedureType>(string storedName, params StoredProcedureParameter[] parameters)
		{
			try
			{
				var result = new List<TStoredProcedureType>();
				using (var sqlCmd = Database.GetStoredProcCommand(storedName))
				{
					sqlCmd.CommandTimeout = TimeOutSeconds;
					PrepareParameters(sqlCmd, parameters);
					using (var reader = Database.ExecuteReader(sqlCmd))
					{
						if (reader.Read())
						{
							result.Add(MapRow<TStoredProcedureType>(reader));
						}
						reader.Close();
						foreach (var parameter in parameters.Where(t => t.Direction == ParameterDirection.Output))
							parameter.Value = Database.GetParameterValue(sqlCmd, parameter.Name);
					}
				}
				Logger.Info($"GetByStoredProcedure<{typeof(TStoredProcedureType).Name}> result: {result.Count}");

				return new List<TStoredProcedureType>(result);
			}
			catch (Exception e)
			{
				Logger.Error($"GetByStoredProcedure<{typeof(TStoredProcedureType).Name}> exception: {e.Message}\n {e.StackTrace}");
				return new List<TStoredProcedureType>();
			}
		}

		public Response CallStoredProcedure(string storedName, params StoredProcedureParameter[] parameters)
		{
			try
			{
				using (var sqlCmd = Database.GetStoredProcCommand(storedName))
				{
					sqlCmd.CommandTimeout = TimeOutSeconds;
					PrepareParameters(sqlCmd, parameters);
					var result = Database.ExecuteNonQuery(sqlCmd);

					foreach (var parameter in parameters.Where(t => t.Direction == ParameterDirection.Output))
						parameter.Value = Database.GetParameterValue(sqlCmd, parameter.Name);

					Logger.Info($"CallStoredProcedure result count: {result}");
				}
				return new Response(true, null);
			}
			catch (Exception e)
			{
				Logger.Error($"CallStoredProcedure exception: {e.Message}\n {e.StackTrace}");
				return new Response(false, CommonMessage.CommonError);
			}
		}
	}
}