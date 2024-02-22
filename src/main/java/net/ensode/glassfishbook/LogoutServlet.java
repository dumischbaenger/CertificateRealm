package net.ensode.glassfishbook;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class LogoutServlet extends HttpServlet
{
  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException
  {
    request.getSession().invalidate();

    response.sendRedirect("index.jsp");
  }
}
