CREATE TABLE [dbo].[UserInfomation] (
    [UserId]      BIGINT          IDENTITY (1, 1) NOT NULL,
    [Username]    NVARCHAR (200)  NOT NULL,
    [Password]    NVARCHAR (1000) NOT NULL,
    [CreatedDate] DATETIME        DEFAULT (getdate()) NULL,
    [UpdatedDate] DATETIME        DEFAULT (getdate()) NULL,
    [FirstName]   NVARCHAR (100)  NULL,
    [LastName]    NVARCHAR (100)  NULL,
    [DoB]         DATETIME        NULL,
    [Email]       NVARCHAR (1000) NOT NULL,
    [PhoneNumber] NVARCHAR (15)   NULL,
    [IsDelete]    BIT             NULL,
    PRIMARY KEY CLUSTERED ([UserId] ASC),
    UNIQUE NONCLUSTERED ([Username] ASC)
);

