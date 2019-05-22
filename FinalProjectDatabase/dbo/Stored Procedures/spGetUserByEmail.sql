CREATE PROC spGetUserByEmail
	@Email NVARCHAR(1000)
AS 
BEGIN
	SELECT [UserId]
      ,[Username]
      ,[CreatedDate]
      ,[UpdatedDate]
      ,[FirstName]
      ,[LastName]
      ,[DoB]
      ,[Email]
      ,[PhoneNumber]
      ,[IsDelete]
  FROM [dbo].[UserInfomation]
  WHERE Email = @Email AND ISNULL(IsDelete,0) = 0
END